import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final _log = Logger('auth');

Middleware supabaseAuth(String url, String publisherKey) {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  final cache = <String, ({String userId, DateTime expiration})>{};

  Future<String?> verify(String token) async {
    final now = DateTime.now();
    cache.removeWhere((_, id) => id.expiration.isBefore(now));

    final hit = cache[token];
    if (hit != null) return hit.userId;

    final req = await client
        .getUrl(Uri.parse('$url/auth/v1/user'))
        .timeout(const Duration(seconds: 10));
    req.headers
      ..set('authorization', 'Bearer $token')
      ..set('apikey', publisherKey);
    final res = await req.close().timeout(const Duration(seconds: 10));
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) return null;

    final id = (jsonDecode(body) as Map)['id'] as String;
    cache[token] = (
      userId: id,
      expiration: now.add(const Duration(minutes: 5)),
    );
    return id;
  }

  return (inner) => (req) async {
    final header = req.headers['authorization'] ?? '';
    if (!header.startsWith('Bearer ')) return Response(401);

    String? userId;
    try {
      userId = await verify(header.substring(7).trim());
    } catch (e) {
      _log.warning('token verification failed', e);
      return Response(503, body: 'auth unavailable');
    }
    if (userId == null) return Response(401);

    return inner(req.change(context: {'userId': userId}));
  };
}
