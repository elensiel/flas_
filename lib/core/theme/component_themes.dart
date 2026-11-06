import 'package:flutter/material.dart';

class ComponentThemes {
  const ComponentThemes._();

  static AppBarTheme appBar(ColorScheme s, String? font) => AppBarTheme(
    backgroundColor: s.surface,
    foregroundColor: s.onSurface,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: font,
      fontSize: 24,
      fontWeight: .w600,
      color: s.onSurface,
    ),
  );

  static BottomSheetThemeData bottomSheet(ColorScheme s) =>
      BottomSheetThemeData(
        backgroundColor: s.surfaceContainerLow,
        showDragHandle: true,
      );

  static DividerThemeData divider(ColorScheme s) =>
      DividerThemeData(color: s.outlineVariant, space: 1);

  static FloatingActionButtonThemeData fab(ColorScheme s) =>
      FloatingActionButtonThemeData(
        backgroundColor: s.primary,
        foregroundColor: s.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      );

  static InputDecorationTheme inputDecoration(ColorScheme s) {
    const borderWidth = 1.5;
    const focusedBorderWidth = 2.0;

    OutlineInputBorder border(Color c, double width) => OutlineInputBorder(
      borderRadius: .circular(12),
      borderSide: BorderSide(color: c, width: width),
    );

    return InputDecorationTheme(
      border: border(s.outlineVariant, borderWidth),
      enabledBorder: border(s.outlineVariant, borderWidth),
      focusedBorder: border(s.outline, focusedBorderWidth),
      errorBorder: border(s.error, borderWidth),
      focusedErrorBorder: border(s.error, focusedBorderWidth),
    );
  }

  static ListTileThemeData listTile(ColorScheme s) => ListTileThemeData(
    iconColor: s.onSurface,
    shape: RoundedRectangleBorder(borderRadius: .circular(12)),
  );

  static NavigationBarThemeData navigationBar(ColorScheme s) =>
      NavigationBarThemeData(
        backgroundColor: s.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (st) => TextStyle(
            fontWeight: st.contains(WidgetState.selected) ? .w600 : .w400,
          ),
        ),
      );

  static PopupMenuThemeData popupMenu(ColorScheme s) => PopupMenuThemeData(
    color: s.surfaceContainerHigh,
    shape: RoundedRectangleBorder(
      borderRadius: .circular(12),
      side: BorderSide(color: s.outlineVariant),
    ),
  );
}
