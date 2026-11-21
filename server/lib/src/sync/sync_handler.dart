import 'dart:convert';

import 'package:flas_server/src/http_helpers.dart';
import 'package:flas_server/src/sync/sync_repository.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class SyncHandler {
  SyncHandler(this._repo);

  final SyncRepository _repo;
  final _log = Logger('sync');

  Router get router => Router()
    ..post('/push', _push)
    ..get('/pull', _pull);

  Future<Response> _push(Request req) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      _repo.push(
        req.userId,
        decks: (body['decks'] as List? ?? []).cast<Map<String, dynamic>>(),
        cards: (body['cards'] as List? ?? []).cast<Map<String, dynamic>>(),
      );
    } catch (e, st) {
      _log.warning('push failed', e, st);
      return .badRequest(body: 'invalid json');
    }
    return .ok('{}', headers: jsonHeaders);
  }

  Response _pull(Request req) {
    final since = int.tryParse(req.url.queryParameters['since'] ?? '') ?? 0;
    final result = _repo.pull(req.userId, since);
    return .ok(jsonEncode(result.toJson()), headers: jsonHeaders);
  }
}
