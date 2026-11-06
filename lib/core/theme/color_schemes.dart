import 'package:flutter/material.dart';

class AppColorSchemes {
  const AppColorSchemes._();

  static const light = ColorScheme(
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
  );

  static const dark = ColorScheme(
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
  );
}
