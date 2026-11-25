import 'package:material_ui/material_ui.dart';

class AppIcons extends ThemeExtension<AppIcons> {
  const AppIcons({
    required this.style,
    required this.menu,
    required this.camera,
  });

  final IconData camera, menu, style;

  static const rounded = AppIcons(
    camera: Icons.camera_rounded,
    menu: Icons.menu_rounded,
    style: Icons.style_rounded,
  );

  @override
  AppIcons copyWith() => this;

  @override
  AppIcons lerp(AppIcons? other, double t) => t < 0.5 ? this : other ?? this;
}
