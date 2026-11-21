import 'dart:io';

import 'package:flas_server/logging.dart';
import 'package:flas_server/src/app.dart';
import 'package:flas_server/src/config.dart';
import 'package:flas_server/src/database/database.dart';
import 'package:flas_server/src/media/media_handler.dart';
import 'package:flas_server/src/media/media_storage.dart';
import 'package:flas_server/src/sync/sync_handler.dart';
import 'package:flas_server/src/sync/sync_repository.dart';
import 'package:flas_server/supabase_auth.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf_io.dart' as io;

Future<void> main() async {
  final Config config;
  try {
    config = Config.fromEnvironment();
  } on StateError catch (e) {
    stderr.writeln(e.message);
    exit(1);
  }

  initlogging();
  final log = Logger('server');

  final db = openAppDatabase(config.dbPath);
  final handler = buildHandler(
    auth: supabaseAuth(config.supabaseUrl, config.supabaseKey),
    sync: SyncHandler(SyncRepository(db)),
    media: MediaHandler(MediaStorage(config.mediaPath)),
  );

  final server = await io.serve(handler, InternetAddress.anyIPv4, config.port);
  log.info('listening on: ${server.port}');

  ProcessSignal.sigint.watch().listen((_) async {
    await server.close();
    db.close();
    exit(0);
  });
}
