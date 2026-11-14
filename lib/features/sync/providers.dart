import 'package:flas_/core/constants.dart';
import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/auth/providers.dart';
import 'package:flas_/features/media/providers.dart';
import 'package:flas_/features/sync/data/sync_local_store.dart';
import 'package:flas_/features/sync/data/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final syncLocalStoreProvider = Provider(
  (ref) => SyncLocalStore(db: ref.watch(dbProvider)),
);

final syncServiceProvider = Provider(
  (ref) => SyncService(
    store: ref.watch(syncLocalStoreProvider),
    media: ref.watch(mediaStoreProvider),
    baseUrl: apiBaseUrl,
    token: () => Supabase.instance.client.auth.currentSession?.accessToken,
    onUnauthorized: () => ref.read(authProvider.notifier).signOut(),
  ),
);
