import 'package:flas_server/src/http_helpers.dart';
import 'package:flas_server/src/media/media_storage.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class MediaHandler {
  MediaHandler(this._storage);

  final MediaStorage _storage;
  final _log = Logger('media');

  Router get router => Router()
    ..put('/<hash>', _put)
    ..get('/<hash>', _get);

  Future<Response> _put(Request req, String hash) async {
    if (!MediaStorage.isValidHash(hash)) return .badRequest();

    try {
      final ok = await _storage.save(req.userId, hash, req.read());
      return ok ? .ok('') : .badRequest(body: 'hash mismatch');
    } catch (e, st) {
      _log.warning('upload failed', e, st);
      return .internalServerError();
    }
  }

  Future<Response> _get(Request req, String hash) async {
    if (!MediaStorage.isValidHash(hash)) return .badRequest();

    final file = _storage.find(req.userId, hash);
    if (file == null) return .notFound('');

    return .ok(
      file.openRead(),
      headers: {
        'content-type': 'application/octet-stream',
        'content-length': '${await file.length()}',
        'cache-control': 'private, max-age=31536000, immutable',
      },
    );
  }
}
