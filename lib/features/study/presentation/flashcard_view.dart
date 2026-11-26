import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/media/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';

class FlashcardView extends ConsumerStatefulWidget {
  const FlashcardView({
    super.key,
    this.frontImage,
    this.backImage,
    required this.frontText,
    required this.backText,
  });

  final String? frontImage, backImage;
  final String? frontText, backText;

  @override
  ConsumerState<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends ConsumerState<FlashcardView> {
  final _gestureController = GestureFlipCardController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(screenMargin),
      child: GestureDetector(
        onTap: _gestureController.flipcard,
        child: GestureFlipCard(
          controller: _gestureController,
          enableController: true,
          animationDuration: context.motion.normal,
          axis: .vertical,
          frontWidget: _side(widget.frontImage, widget.frontText),
          backWidget: _side(widget.backImage, widget.backText),
        ),
      ),
    );
  }

  Widget _side(String? imageHash, String? text) {
    final theme = Theme.of(context);

    return Container(
      width: .infinity,
      decoration: BoxDecoration(
        border: .all(color: theme.colorScheme.outline, width: 1.5),
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
              if (text!.isNotEmpty == true)
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
