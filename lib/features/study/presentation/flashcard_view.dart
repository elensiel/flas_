import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/media/providers.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlashcardView extends ConsumerWidget {
  const FlashcardView({
    super.key,
    this.frontImage,
    this.backImage,
    required this.frontText,
    required this.backText,
  });

  final String? frontImage, backImage;
  final String frontText, backText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: .all(screenMargin),
      child: FlipCard(
        fill: .fillBack,
        front: _side(context, ref, frontImage, frontText),
        back: _side(context, ref, backImage, backText),
      ),
    );
  }

  Widget _side(
    BuildContext context,
    WidgetRef ref,
    String? imageHash,
    String text,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: .infinity,
      decoration: BoxDecoration(
        border: .all(color: colorScheme.outline, width: 1.5),
        borderRadius: .circular(24),
      ),
      padding: const .all(20),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            spacing: 16,
            children: [
              if (imageHash != null)
                ref
                    .watch(mediaFileProvider(imageHash))
                    .when(
                      data: (f) => f == null
                          ? const SizedBox.shrink()
                          : ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 248),
                              child: ClipRRect(
                                borderRadius: .circular(12),
                                child: Image.file(f, fit: .contain),
                              ),
                            ),
                      error: (_, _) => Icon(context.icons.brokenImage),
                      loading: () => const CircularProgressIndicator.adaptive(),
                    ),
              Text(
                text,
                textAlign: .justify,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: .w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
