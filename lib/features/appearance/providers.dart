import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/appearance/data/appearance_store.dart';
import 'package:flas_/features/appearance/domain/appearance_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appearanceStoreProvider = Provider(
  (ref) => AppearanceStore(ref.watch(dbProvider)),
);

final initialAppearanceProvider = Provider<AppearanceSettings>(
  (_) => throw UnimplementedError(),
);

final appearanceProvider =
    NotifierProvider<AppearanceNotifier, AppearanceSettings>(
      AppearanceNotifier.new,
    );

class AppearanceNotifier extends Notifier<AppearanceSettings> {
  @override
  AppearanceSettings build() => ref.read(initialAppearanceProvider);

  void update(AppearanceSettings Function(AppearanceSettings) change) {
    state = change(state);
    ref.read(appearanceStoreProvider).save(state);
  }
}
