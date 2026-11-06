import 'package:flas_/core/database/app_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
