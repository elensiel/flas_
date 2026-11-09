import 'package:flutter/material.dart';

@immutable
class AppMotion extends ThemeExtension<AppMotion> {
  const AppMotion({this.scale = 1});

  final double scale;

  Duration get fast => _scaled(150);
  Duration get normal => _scaled(300);
  Duration get slow => _scaled(500);

  Curve get standard => Curves.easeInOut;
  Curve get emphasized => Curves.easeOutCubic;

  Duration _scaled(int ms) => Duration(milliseconds: (ms * scale).round());

  @override
  AppMotion copyWith({double? scale}) => AppMotion(scale: scale ?? this.scale);

  @override
  AppMotion lerp(AppMotion? other, double t) =>
      AppMotion(scale: scale + ((other?.scale ?? scale) - scale) * t);
}
