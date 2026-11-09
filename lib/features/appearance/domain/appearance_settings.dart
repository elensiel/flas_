import 'package:flas_/core/theme/icons.dart';
import 'package:flutter/material.dart';

enum AppIconSet {
  rounded(AppIcons.rounded),
  outlined(AppIcons.outlined);

  const AppIconSet(this.icons);
  final AppIcons icons;
}

enum MotionSpeed {
  off(0),
  fast(0.5),
  normal(1),
  slow(1.5);

  const MotionSpeed(this.scale);
  final double scale;
}

@immutable
class AppearanceSettings {
  const AppearanceSettings({
    this.themeMode = .system,
    this.fontId = 'fredoka',
    this.iconSet = .rounded,
    this.motion = .normal,
  });

  final ThemeMode themeMode;
  final String fontId;
  final AppIconSet iconSet;
  final MotionSpeed motion;

  AppearanceSettings copyWith({
    ThemeMode? themeMode,
    String? fontId,
    AppIconSet? iconSet,
    MotionSpeed? motion,
  }) => AppearanceSettings(
    themeMode: themeMode ?? this.themeMode,
    fontId: fontId ?? this.fontId,
    iconSet: iconSet ?? this.iconSet,
    motion: motion ?? this.motion,
  );
}
