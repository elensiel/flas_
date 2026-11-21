import 'package:flas_/core/theme/theme_context.dart';
import 'package:material_ui/material_ui.dart';

class AppPopupMenuButton<T> extends StatelessWidget {
  const AppPopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.onSelected,
    this.icon,
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T>? onSelected;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => PopupMenuButton<T>(
    itemBuilder: itemBuilder,
    onSelected: onSelected,
    icon: icon,
    popUpAnimationStyle: context.motion.scale == 0
        ? .noAnimation
        : AnimationStyle(
            curve: context.motion.emphasized,
            duration: context.motion.fast,
            reverseDuration: context.motion.fast,
          ),
  );
}
