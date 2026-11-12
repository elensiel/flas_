import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flas_server/auth.dart';
import 'package:flas_server/logging.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

final db = sqlite3.open('flas_server.db');
final mediaDir = Directory('media')..createSync(recursive: true);
final _log = Logger('flas_server');

void initDb() => db.execute('''
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;
PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at INTEGER NOT NULL
)

CREATE TABLE IF NOT EXISTS sessions(
  token_hash TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  expires_at INTEGER NOT NULL
)
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);

CREATE TABLE IF NOT EXISTS decks( 
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  id TEXT PRIMARY KEY, 
  name TEXT NOT NULL, 
  description TEXT NOT NULL, 
  updated_at INTEGER NOT NULL, 
  deleted_at INTEGER, 
  seq INTEGER NOT NULL,
  PRIMARY KEY(user_id, id)
);

CREATE TABLE IF NOT EXISTS cards(
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  id TEXT PRIMARY KEY, 
  deck_id TEXT NOT NULL,
  front_text TEXT NOT NULL, 
  front_image TEXT,
  back_text TEXT NOT NULL, 
  back_image TEXT,
  position INTEGER NOT NULL, 
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER, 
  seq INTEGER NOT NULL,
  PRIMARY KEY(user_id, id)
);

CREATE INDEX IF NOT EXISTS idx_decks_seq ON decks(user_id, seq);
CREATE INDEX IF NOT EXISTS idx_cards_seq ON cards(user_id, seq);

CREATE TABLE IF NOT EXISTS meta(
  key TEXT PRIMARY KEY, 
  value INTEGER NOT NULL
);
INSERT OR IGNORE INTO meta VALUES('seq', 0);
''');

late final PreparedStatement _nextSeq,
    _currentSeq,
    _upsertDeck,
    _upsertCard,
    _pullDecks,
    _pullCards;

void prepare() {
  _nextSeq = db.prepare(
    "UPDATE meta SET value = value + 1 WHERE key='seq' RETURNING value",
  );
  _currentSeq = db.prepare("SELECT value FROM meta WHERE key='seq'");
  _upsertDeck = db.prepare('''
    INSERT INTO decks(user_id, id, name, description, updated_at, deleted_at, seq)
    VALUES(?,?,?,?,?,?,?)
    ON CONFLICT(uesr_id, id) DO UPDATE SET
      name=excluded.name,
      description=excluded.description,
      updated_at=excluded.updated_at,
      deleted_at=excluded.deleted_at,
      seq=excluded.seq
    WHERE excluded.updated_at >= decks.updated_at
    ''');
  _upsertCard = db.prepare('''
    INSERT INTO cards(
      user_id, id, deck_id, front_text, front_image, 
      back_text, back_image, position, 
      updated_at, deleted_at, seq
    )
    VALUES(?,?,?,?,?,?,?,?,?,?,?)
    ON CONFLICT(user_id, id) DO UPDATE SET
      deck_id=excluded.deck_id,
      front_text=excluded.front_text,
      front_image=excluded.front_image,
      back_text=excluded.back_text,
      back_image=excluded.back_image,
      position=excluded.position,
      updated_at=excluded.updated_at,
      deleted_at=excluded.deleted_at,
      seq=excluded.seq
    WHERE excluded.updated_at >= cards.updated_at
    ''');
  _pullDecks = db.prepare(
    'SELECT * FROM decks WHERE user_id = ? AND seq > ? ORDER BY seq',
  );
  _pullCards = db.prepare(
    'SELECT * FROM cards WHERE user_id = ? AND seq > ? ORDER BY seq',
  );
}

int currentSeq() => _currentSeq.select().first['value'] as int;
int nextSeq() => _nextSeq.select().first['value'] as int;

int _userId(Request req) => req.context['userId'] as int;

final _jsonHeaders = {'content-type': 'application/json'};

Future<Response> push(Request req) async {
  final userId = _userId(req);
  final Map<String, dynamic> body;
  try {
    body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
  } catch (_) {
    return .badRequest(body: 'invalid json');
  }

  db.execute('BEGIN');
  try {
    for (final d in (body['decks'] as List? ?? [])) {
      _upsertDeck.execute([
        userId,
        d['id'],
        d['name'],
        d['description'],
        d['updatedAt'],
        d['deletedAt'],
        nextSeq(),
      ]);
    }
    for (final c in (body['cards'] as List? ?? [])) {
      _upsertCard.execute([
        userId,
        c['id'],
        c['deckId'],
        c['frontText'],
        c['frontImage'],
        c['backText'],
        c['backImage'],
        c['position'],
        c['updatedAt'],
        c['deletedAt'],
        nextSeq(),
      ]);
    }
    db.execute('COMMIT');
  } catch (e, stackTrace) {
    db.execute('ROLLBACK');
    _log.warning('push failed: $e', stackTrace);
    return .badRequest(body: 'invalid payload');
  }
  return .ok('{}', headers: _jsonHeaders);
}

Response pull(Request req) {
  final userId = _userId(req);
  final since = int.tryParse(req.url.queryParameters['since'] ?? '') ?? 0;
  final cursor = currentSeq();

  final decks = [
    for (final r in _pullDecks.select([userId, since]))
      {
        'id': r['id'],
        'name': r['name'],
        'description': r['description'],
        'updatedAt': r['updated_at'],
        'deletedAt': r['deleted_at'],
      },
  ];

  final cards = [
    for (final r in _pullCards.select([userId, since]))
      {
        'id': r['id'],
        'deckId': r['deck_id'],
        'frontText': r['front_text'],
        'frontImage': r['front_image'],
        'backText': r['back_text'],
        'backImage': r['back_image'],
        'position': r['position'],
        'updatedAt': r['updated_at'],
        'deletedAt': r['deleted_at'],
      },
  ];

  return .ok(
    jsonEncode({'decks': decks, 'cards': cards, 'cursor': cursor}),
    headers: _jsonHeaders,
  );
}

final _validHash = RegExp(r'^[a-f0-9]{64}$');

Directory _userMediaDir(int userId) =>
    Directory('${mediaDir.path}/$userId')..createSync(recursive: true);

Future<Response> putMedia(Request req, String hash) async {
  if (!_validHash.hasMatch(hash)) return .badRequest();

  final dir = _userMediaDir(_userId(req));
  final destination = File('${dir.path}/$hash');
  if (destination.existsSync()) return .ok('');

  final tmp = File('${dir.path}/$hash.tmp');
  try {
    await req.read().pipe(tmp.openWrite());
    final digest = await sha256.bind(tmp.openRead()).first;
    if (digest.toString() != hash) {
      await tmp.delete();
      return .badRequest(body: 'hash mismatch');
    }
    await tmp.rename(destination.path);
  } catch (_) {
    if (tmp.existsSync()) await tmp.delete();
    return .internalServerError();
  }
  return .ok('');
}

Future<Response> getMedia(Request req, String hash) async {
  if (!_validHash.hasMatch(hash)) return .badRequest();

  final f = File('${mediaDir.path}/${_userId(req)}/$hash');
  if (!f.existsSync()) return .notFound('');

  return .ok(
    f.openRead(),
    headers: {
      'content-type': 'application/octet-stream',
      'content-length': '${await f.length()}',
      'cache-control': 'public, max-age=31536000, immutable',
    },
  );
}

Future<void> main() async {
  initlogging();
  initDb();
  prepare();

  final auth = AuthService(db)..purgeExpired();
  Timer.periodic(const Duration(hours: 1), (_) => auth.purgeExpired());

  final router = Router()
    ..post('/auth/register', auth.register)
    ..post('/auth/login', auth.login)
    ..post('/auth/logout', auth.logout)
    ..post('/sync/push', push)
    ..get('/sync/pull', pull)
    ..put('/media/<hash>', putMedia)
    ..get('/media/<hash>', getMedia);

  final handler = const Pipeline()
      .addMiddleware(
        logRequests(
          logger: ((message, isError) =>
              isError ? _log.severe(message) : _log.info(message)),
        ),
      )
      .addMiddleware(auth.middleware())
      .addHandler(router.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  _log.info('listening on :${server.port}');
}
