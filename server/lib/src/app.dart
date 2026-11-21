import 'package:flas_server/src/media/media_handler.dart';
import 'package:flas_server/src/sync/sync_handler.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Handler buildHandler({
  required Middleware auth,
  required SyncHandler sync,
  required MediaHandler media,
}) {
  final log = Logger('http');

  final router = Router()
    ..mount('/sync/', sync.router.call)
    ..mount('/media/', media.router.call);

  return const Pipeline()
      .addMiddleware(
        logRequests(
          logger: (message, isError) =>
              isError ? log.severe(message) : log.info(message),
        ),
      )
      .addMiddleware(auth)
      .addHandler(router.call);
}
