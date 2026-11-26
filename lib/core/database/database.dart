import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Decks, Cards, MediaFiles, SyncState])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'flas_'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // dev only
      if (kDebugMode) {
        final m = createMigrator();
        for (final table in allTables.toList().reversed) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
      }
    },
  );
}
