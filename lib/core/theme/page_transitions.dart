import 'package:flas_/core/theme/motion.dart';
import 'package:material_ui/material_ui.dart';

class ScaledPageTransitionsBuilder extends PageTransitionsBuilder {
  const ScaledPageTransitionsBuilder(this.base, this.scale);

  final PageTransitionsBuilder base;
  final double scale;

  Duration _scaled(Duration d) =>
      Duration(milliseconds: (d.inMilliseconds * scale).round());

  @override
  Duration get transitionDuration => _scaled(base.transitionDuration);

  @override
  Duration get reverseTransitionDuration =>
      _scaled(base.reverseTransitionDuration);

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      base.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => base.buildTransitions<T>(
    route,
    context,
    animation,
    secondaryAnimation,
    child,
  );
}

PageTransitionsTheme appPageTransitions(AppMotion motion) =>
    PageTransitionsTheme(
      builders: {
        for (final e in const PageTransitionsTheme().builders.entries)
          e.key: ScaledPageTransitionsBuilder(e.value, motion.scale),
      },
    );
