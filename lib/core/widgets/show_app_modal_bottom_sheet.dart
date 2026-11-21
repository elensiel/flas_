import 'package:flas_/core/theme/theme_context.dart';
import 'package:material_ui/material_ui.dart';

Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showModalBottomSheet(
  context: context,
  builder: builder,
  sheetAnimationStyle: context.motion.scale == 0
      ? .noAnimation
      : AnimationStyle(
          duration: context.motion.normal,
          reverseDuration: context.motion.normal,
          curve: context.motion.emphasized,
          reverseCurve: context.motion.emphasized,
        ),
);
