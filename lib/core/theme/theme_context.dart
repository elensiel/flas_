import 'package:flas_/core/theme/icons.dart';
import 'package:flas_/core/theme/motion.dart';
import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  AppIcons get icons => Theme.of(this).extension<AppIcons>()!;

  AppMotion get motion {
    final motion = Theme.of(this).extension<AppMotion>()!;
    return MediaQuery.disableAnimationsOf(this)
        ? motion.copyWith(scale: 0)
        : motion;
  }
}
