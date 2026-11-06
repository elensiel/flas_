import 'package:flutter/material.dart';

class AppTheme {
  static final String _fontFamily = 'Fredoka';

  static ThemeData get light => _build(
    const ColorScheme(
      brightness: .light,
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Color(0xFF3A3A3A),
      outline: Colors.black,
      outlineVariant: Color(0xFFBDBDBD),
      surfaceContainerLow: Color(0xFFF7F7F7),
      surfaceContainerHigh: Color(0xFFE8E8E8),
      surfaceTint: Colors.transparent,
    ),
  );

  static ThemeData get dark => _build(
    const ColorScheme(
      brightness: .dark,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.white,
      onSecondary: Colors.black,
      error: Color(0xFFFF6B6B),
      onError: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFCFCFCF),
      outline: Colors.white,
      outlineVariant: Color(0xFF4A4A4A),
      surfaceContainerLow: Color(0xFF0D0D0D),
      surfaceContainerHigh: Color(0xFF1F1F1F),
      surfaceTint: Colors.transparent,
    ),
  );

  static ThemeData _build(ColorScheme s) {
    const borderWidth = 1.5;
    const focusedBorderWidth = 2.0;

    OutlineInputBorder border(Color c, double width) => OutlineInputBorder(
      borderRadius: .circular(12),
      borderSide: BorderSide(color: c, width: width),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: s,
      scaffoldBackgroundColor: s.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: s.surface,
        foregroundColor: s.onSurface,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: .w600,
          color: s.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: s.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (st) => TextStyle(
            fontWeight: st.contains(WidgetState.selected) ? .w600 : .w400,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: s.onSurface,
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: border(s.outlineVariant, borderWidth),
        enabledBorder: border(s.outlineVariant, borderWidth),
        focusedBorder: border(s.outline, focusedBorderWidth),
        errorBorder: border(s.error, borderWidth),
        focusedErrorBorder: border(s.error, focusedBorderWidth),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: s.primary,
        foregroundColor: s.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      ),
      dividerTheme: DividerThemeData(color: s.outlineVariant, space: 1),
      popupMenuTheme: PopupMenuThemeData(
        color: s.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: .circular(12),
          side: BorderSide(color: s.outlineVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.surfaceContainerLow,
        showDragHandle: true,
      ),
    );
  }
}
