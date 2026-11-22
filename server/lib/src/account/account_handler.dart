import 'dart:convert';
import 'dart:io';

import 'package:flas_server/src/http_helpers.dart';
import 'package:flas_server/src/media/media_storage.dart';
import 'package:flas_server/src/sync/sync_repository.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

class AccountHandler {
  AccountHandler({
    required this.sync,
    required this.media,
    required this.supabaseUrl,
    required this.secretKey,
  });

  final SyncRepository sync;
  final MediaStorage media;
  final String supabaseUrl, secretKey;
  final _log = Logger('account');
  final _client = HttpClient()..connectionTimeout = const Duration(seconds: 10);

  Future<Response> delete(Request req) async {
    final userId = req.context['userId'] as String;

    try {
      sync.deleteUser(userId);
      await _deleteAuthUser(userId);
    } catch (e, st) {
      _log.severe('account deletion failed for $userId', e, st);
      return Response(502, body: 'deletion failed');
    }

    try {
      await media.delete(userId);
    } catch (e, st) {
      _log.warning('media cleanup failed for $userId', e, st);
    }

    return .ok(jsonEncode({}), headers: jsonHeaders);
  }

  Future<void> _deleteAuthUser(String userId) async {
    final req = await _client
        .deleteUrl(Uri.parse('$supabaseUrl/auth/v1/admin/users/$userId'))
        .timeout(const Duration(seconds: 10));
    req.headers.set('apikey', secretKey);
    final res = await req.close().timeout(const Duration(seconds: 10));
    await res.drain<void>();
    if (res.statusCode != 200 && res.statusCode != 404) {
      throw HttpException('supabase admin delete: ${res.statusCode}');
    }
  }
}
