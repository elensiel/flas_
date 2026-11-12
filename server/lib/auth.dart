import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

const _sessionTtl = Duration(days: 30);
const _publicPaths = {'auth/register', 'auth/login'};
const _sqliteConstraintUnique = 2067;

final _validEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final _log = Logger('auth');

int _now() => DateTime.now().millisecondsSinceEpoch;

Response _json(int status, Map<String, Object?> body) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': 'application/json'},
);

Response _error(int status, String message) =>
    _json(status, {'error': message});

String _newToken() {
  final rng = Random.secure();
  final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}

String _hashToken(String token) =>
    sha256.convert(utf8.encode(token)).toString();

String _clientIp(Request req) {
  final info = req.context['shelf.io.connection_info'] as HttpConnectionInfo?;
  return info?.remoteAddress.address ?? 'unknown';
}

class _RateLimiter {
  static final int max = 5;
  static final Duration window = Duration(minutes: 15);

  final _fails = <String, List<DateTime>>{};

  bool blocked(String key) {
    final list = _fails[key];
    if (list == null) return false;

    final cutoff = DateTime.now().subtract(window);
    list.removeWhere((time) => time.isBefore(cutoff));
    if (list.isEmpty) {
      _fails.remove(key);
      return false;
    }
    return list.length >= max;
  }

  void fail(String key) => (_fails[key] ??= []).add(DateTime.now());

  void reset(String key) => _fails.remove(key);
}

class AuthService {
  AuthService(this.db) {
    _insertUser = db.prepare(
      'INSERT INTO users(email, password_hash, created_at) VALUES(?,?,?)',
    );
    _findUser = db.prepare(
      'SELECT id, password_hash FROM users WHERE email = ?',
    );
    _insertSession = db.prepare(
      'INSERT INTO sessions(token_hash, user_id, expires_at) VALUES(?,?,?)',
    );
    _findSession = db.prepare(
      'SELECT user_id FROM sessions WHERE token_hash = ? AND expires_at > ?',
    );
    _deleteSession = db.prepare('DELETE FROM sessions WHERE token_hash = ?');
    _purge = db.prepare('DELETE FROM sessions WHERE expires_at <= ?');
  }

  final Database db;
  final _limiter = _RateLimiter();

  late final PreparedStatement _insertUser,
      _findUser,
      _insertSession,
      _findSession,
      _deleteSession,
      _purge;

  late final String _dummyHash = BCrypt.hashpw('dummy', BCrypt.gensalt());

  void purgeExpired() => _purge.execute([_now()]);

  Middleware middleware() =>
      (inner) => (req) {
        if (_publicPaths.contains(req.url.path)) return inner(req);

        final header = req.headers['authorization'] ?? '';
        if (!header.startsWith('Bearer ')) {
          return _error(401, 'unauthorized');
        }

        final tokenHash = _hashToken(header.substring(7).trim());
        final row = _findSession.select([tokenHash, _now()]).firstOrNull;
        if (row == null) return _error(401, 'unauthorized');

        return inner(
          req.change(
            context: {'userId': row['user_id'] as int, 'tokenHash': tokenHash},
          ),
        );
      };

  Future<Response> register(Request req) async {
    final creds = await _readCreds(req);
    if (creds == null) return _error(400, 'invalid request');

    final (:email, :password) = creds;
    if (!_validEmail.hasMatch(email)) return _error(400, 'invalid email');

    final passwordBytes = utf8.encode(password).length;
    if (password.length < 8 || passwordBytes > 72) {
      return _error(400, 'password must be 8-72 characters');
    }

    final hash = await Isolate.run(
      () => BCrypt.hashpw(password, BCrypt.gensalt()),
    );

    try {
      _insertUser.execute([email, hash, _now()]);
    } on SqliteException catch (e) {
      if (e.extendedResultCode == _sqliteConstraintUnique) {
        return _error(409, 'email alrready registered');
      }
      rethrow;
    }
    return _issueSession(db.lastInsertRowId);
  }

  Future<Response> login(Request req) async {
    final ip = _clientIp(req);
    if (_limiter.blocked(ip)) return _error(429, 'too many attempts');

    final creds = await _readCreds(req);
    if (creds == null) return _error(400, 'invalid request');

    final (:email, :password) = creds;
    final row = _findUser.select([email]).firstOrNull;
    final stored = row?['password_hash'] as String? ?? _dummyHash;
    final matches = await Isolate.run(() => BCrypt.checkpw(password, stored));

    if (row == null || !matches) {
      _limiter.fail(ip);
      _log.info('failed login from $ip');
      return _error(401, 'invalid credentials');
    }
    _limiter.reset(ip);
    return _issueSession(row['id'] as int);
  }

  Response logout(Request req) {
    _deleteSession.execute([req.context['tokenHash']]);
    return _json(200, {});
  }

  Response _issueSession(int userId) {
    final token = _newToken();
    final expiresAt = _now() + _sessionTtl.inMilliseconds;
    _insertSession.execute([_hashToken(token), userId, expiresAt]);
    return _json(200, {'token': token, 'expiresAt': expiresAt});
  }

  Future<({String email, String password})?> _readCreds(Request req) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      return (
        email: (body['email'] as String).trim().toLowerCase(),
        password: body['password'] as String,
      );
    } catch (e) {
      return null;
    }
  }
}
