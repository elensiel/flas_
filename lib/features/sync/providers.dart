import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/sync/data/sync_local_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncLocalStoreProvider = Provider(
  (ref) => SyncLocalStore(db: ref.watch(dbProvider)),
);
