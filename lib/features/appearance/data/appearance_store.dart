import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/features/appearance/domain/appearance_settings.dart';
import 'package:flutter/material.dart';

class AppearanceStore {
  const AppearanceStore(this.db);

  final AppDatabase db;
  static const _id = 'local';

  T _resolve<T extends Enum>(List<T> values, String name, T fallback) =>
      values.firstWhere((e) => e.name == name, orElse: () => fallback);

  Future<AppearanceSettings> load() async {
    const defaultSettings = AppearanceSettings();
    final saved = await (db.select(
      db.appearances,
    )..where((a) => a.id.equals(_id))).getSingleOrNull();

    if (saved == null) return defaultSettings;

    return AppearanceSettings(
      themeMode: _resolve(
        ThemeMode.values,
        saved.themeMode,
        defaultSettings.themeMode,
      ),
      fontId: saved.fontId,
      iconSet: _resolve(
        AppIconSet.values,
        saved.iconSet,
        defaultSettings.iconSet,
      ),
      motion: _resolve(
        MotionSpeed.values,
        saved.motion,
        defaultSettings.motion,
      ),
    );
  }

  Future<void> save(AppearanceSettings s) => db
      .into(db.appearances)
      .insertOnConflictUpdate(
        AppearancesCompanion.insert(
          id: _id,
          themeMode: s.themeMode.name,
          fontId: s.fontId,
          iconSet: s.iconSet.name,
          motion: s.motion.name,
        ),
      );
}
