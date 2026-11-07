import 'package:flas_/core/theme/theme_context.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.currentIndex,
    required this.cardCount,
  });

  final int currentIndex;
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (currentIndex + 1) / cardCount;

    return Column(
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              '${currentIndex + 1} / $cardCount',
              style: theme.textTheme.labelLarge,
            ),
            Text(
              '${((currentIndex + 1) / cardCount * 100).round()}%',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: context.motion.fast,
          curve: context.motion.emphasized,
          builder: (_, value, _) => ClipRRect(
            borderRadius: .circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: colorScheme.primary,
              backgroundColor: colorScheme.outlineVariant,
            ),
          ),
        ),
      ],
    );
  }
}
