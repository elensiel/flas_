import 'package:flas_/core/theme/icons.dart';
import 'package:material_ui/material_ui.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build({
    required Brightness brightness,
    AppIcons icons = .rounded,
  }) => ThemeData(brightness: brightness, extensions: [icons]);
}
