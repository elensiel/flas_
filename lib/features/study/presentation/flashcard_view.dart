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
      padding: const EdgeInsets.all(8.0),
      child: FlipCard(
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
  ) => Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        spacing: 8,
        children: [
          if (imageHash != null)
            ref
                .watch(mediaFileProvider(imageHash))
                .when(
                  data: (f) => ClipRect(child: Image.file(f!, fit: .contain)),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, _) => const Icon(Icons.broken_image),
                ),
          Text(
            text,
            textAlign: .justify,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ],
      ),
    ),
  );
}
