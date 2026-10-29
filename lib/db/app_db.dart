import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [Decks, Cards, MediaFiles, SyncState])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'flas'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
