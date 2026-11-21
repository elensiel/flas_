import 'package:flas_/core/theme/color_schemes.dart';
import 'package:flas_/core/theme/component_themes.dart';
import 'package:flas_/core/theme/icons.dart';
import 'package:flas_/core/theme/motion.dart';
import 'package:flas_/core/theme/page_transitions.dart';
import 'package:material_ui/material_ui.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build({
    required Brightness brightness,
    String? fontFamily = 'Fredoka',
    AppIcons icons = AppIcons.rounded,
    AppMotion motion = const AppMotion(),
  }) {
    final colors = brightness == Brightness.light
        ? AppColorSchemes.light
        : AppColorSchemes.dark;

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: ComponentThemes.appBar(colors, fontFamily),
      bottomSheetTheme: ComponentThemes.bottomSheet(colors),
      dividerTheme: ComponentThemes.divider(colors),
      expansionTileTheme: ComponentThemes.expansionTile(motion),
      floatingActionButtonTheme: ComponentThemes.fab(colors),
      inputDecorationTheme: ComponentThemes.inputDecoration(colors),
      listTileTheme: ComponentThemes.listTile(colors),
      navigationBarTheme: ComponentThemes.navigationBar(colors),
      pageTransitionsTheme: appPageTransitions(motion),
      popupMenuTheme: ComponentThemes.popupMenu(colors),
      extensions: [icons, motion],
    );
  }
}
