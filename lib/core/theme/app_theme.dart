import 'package:flas_/core/theme/color_schemes.dart';
import 'package:flas_/core/theme/component_themes.dart';
import 'package:flas_/core/theme/icons.dart';
import 'package:flas_/core/theme/motion.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build({
    required Brightness brightness,
    String? fontFamily = 'Fredoka',
    AppIcons icons = AppIcons.rounded,
    AppMotion motion = const AppMotion(),
  }) {
    final s = brightness == Brightness.light
        ? AppColorSchemes.light
        : AppColorSchemes.dark;

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: s,
      scaffoldBackgroundColor: s.surface,
      appBarTheme: ComponentThemes.appBar(s, fontFamily),
      bottomSheetTheme: ComponentThemes.bottomSheet(s),
      dividerTheme: ComponentThemes.divider(s),
      floatingActionButtonTheme: ComponentThemes.fab(s),
      inputDecorationTheme: ComponentThemes.inputDecoration(s),
      listTileTheme: ComponentThemes.listTile(s),
      navigationBarTheme: ComponentThemes.navigationBar(s),
      popupMenuTheme: ComponentThemes.popupMenu(s),
      extensions: [icons, motion],
    );
  }
}
