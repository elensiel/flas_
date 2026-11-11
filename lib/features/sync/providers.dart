import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/media/providers.dart';
import 'package:flas_/features/sync/data/sync_local_store.dart';
import 'package:flas_/features/sync/data/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncLocalStoreProvider = Provider(
  (ref) => SyncLocalStore(db: ref.watch(dbProvider)),
);

final syncServiceProvider = Provider(
  (ref) => SyncService(
    store: ref.watch(syncLocalStoreProvider),
    media: ref.watch(mediaStoreProvider),
    baseUrl: 'http://10.0.2.2:8080',
    token: 'dev-token',
  ),
);
