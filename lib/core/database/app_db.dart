import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [Decks, Cards, MediaFiles, Appearances, SyncState])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'flas'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.renameColumn(decks, 'title', decks.name);
      if (from < 3) await m.createIndex(idxCardsDirty);
      if (from < 4) await m.createTable(appearances);
    },
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
