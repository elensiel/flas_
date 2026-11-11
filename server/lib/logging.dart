import 'dart:io';

import 'package:logging/logging.dart';

void initlogging({Level level = .INFO}) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((log) {
    stderr.writeln(
      '${log.time.toIso8601String()} [${log.level.name}] ${log.loggerName}: ${log.message}',
    );
    if (log.error != null) stderr.writeln(log.error);
    if (log.stackTrace != null) stderr.writeln(log.stackTrace);
  });
}
