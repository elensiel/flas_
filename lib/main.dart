import 'package:flas_/app/app.dart';
import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/appearance/data/appearance_store.dart';
import 'package:flas_/features/appearance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        initialAppearanceProvider.overrideWithValue(
          await AppearanceStore(db).load(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}
