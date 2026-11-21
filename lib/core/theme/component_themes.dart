import 'package:flas_/core/theme/motion.dart';
import 'package:material_ui/material_ui.dart';

class ComponentThemes {
  const ComponentThemes._();

  static AppBarTheme appBar(ColorScheme colors, String? font) => AppBarTheme(
    backgroundColor: colors.surface,
    foregroundColor: colors.onSurface,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: font,
      fontSize: 24,
      fontWeight: .w600,
      color: colors.onSurface,
    ),
  );

  static BottomSheetThemeData bottomSheet(ColorScheme colors) =>
      BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLow,
        showDragHandle: true,
      );

  static DividerThemeData divider(ColorScheme colors) =>
      DividerThemeData(color: colors.outlineVariant, space: 1);

  static ExpansionTileThemeData expansionTile(AppMotion m) =>
      ExpansionTileThemeData(
        expansionAnimationStyle: AnimationStyle(
          duration: m.normal,
          reverseDuration: m.normal,
          curve: m.standard,
          reverseCurve: m.standard,
        ),
      );

  static FloatingActionButtonThemeData fab(ColorScheme colors) =>
      FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      );

  static InputDecorationTheme inputDecoration(ColorScheme colors) {
    const borderWidth = 1.5;
    const focusedBorderWidth = 2.0;

    OutlineInputBorder border(Color c, double width) => OutlineInputBorder(
      borderRadius: .circular(12),
      borderSide: BorderSide(color: c, width: width),
    );

    return InputDecorationTheme(
      border: border(colors.outlineVariant, borderWidth),
      enabledBorder: border(colors.outlineVariant, borderWidth),
      focusedBorder: border(colors.outline, focusedBorderWidth),
      errorBorder: border(colors.error, borderWidth),
      focusedErrorBorder: border(colors.error, focusedBorderWidth),
    );
  }

  static ListTileThemeData listTile(ColorScheme colors) => ListTileThemeData(
    iconColor: colors.onSurface,
    shape: RoundedRectangleBorder(borderRadius: .circular(12)),
  );

  static NavigationBarThemeData navigationBar(ColorScheme colors) =>
      NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (state) => TextStyle(
            fontWeight: state.contains(WidgetState.selected) ? .w600 : .w400,
          ),
        ),
      );

  static PopupMenuThemeData popupMenu(ColorScheme colors) => PopupMenuThemeData(
    color: colors.surfaceContainerHigh,
    shape: RoundedRectangleBorder(
      borderRadius: .circular(12),
      side: BorderSide(color: colors.outlineVariant),
    ),
  );
}
