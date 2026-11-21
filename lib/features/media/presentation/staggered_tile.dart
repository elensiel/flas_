import 'package:material_ui/material_ui.dart';

class StaggeredTile extends StatelessWidget {
  const StaggeredTile({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    final start = 0.3 + index * 0.15;
    final curved = route.drive(
      CurveTween(
        curve: Interval(start, start + 0.4, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: curved.drive(Tween(begin: const Offset(0.1, 0), end: .zero)),
        child: child,
      ),
    );
  }
}
