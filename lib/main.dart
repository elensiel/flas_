import 'package:flas_/app/app.dart';
import 'package:flas_/core/constants.dart';
import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/core/database/provider.dart';
import 'package:flas_/core/logging.dart';
import 'package:flas_/features/appearance/data/appearance_store.dart';
import 'package:flas_/features/appearance/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  assert(supabaseUrl.isNotEmpty, 'Missing SUPABASE_URL');
  assert(supabasePublishableKey.isNotEmpty, 'Missing SUPABASE_PUBLISHABLE_KEY');

  initLogging();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

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
