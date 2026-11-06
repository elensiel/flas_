import 'dart:io';

import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/media/data/media_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaStoreProvider = Provider((ref) => MediaStore(ref.watch(dbProvider)));

final mediaFileProvider = FutureProvider.family<File?, String>(
  (ref, hash) => ref.watch(mediaStoreProvider).file(hash),
);
