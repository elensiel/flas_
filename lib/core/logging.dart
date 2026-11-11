import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

void initlogging({Level level = .INFO}) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((log) {
    debugPrint(
      '${log.time.toIso8601String()} [${log.level.name}] ${log.loggerName}: ${log.message}',
    );
    if (log.error != null) debugPrint('log.error');
    if (log.stackTrace != null) debugPrint('log.stackTrace');
  });
}
