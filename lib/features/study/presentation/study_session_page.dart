import 'package:flas_/core/constants.dart';
import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/decks/providers.dart';
import 'package:flas_/features/study/presentation/flashcard_view.dart';
import 'package:flas_/features/study/presentation/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudySessionPage extends ConsumerStatefulWidget {
  const StudySessionPage({super.key, required this.deck});

  final Deck deck;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudySessionPageState();
}

class _StudySessionPageState extends ConsumerState<StudySessionPage> {
  int _cardIndex = 0;

  void _move(int delta, int length) {
    final next = _cardIndex + delta;
    if (next >= 0 && next < length) setState(() => _cardIndex = next);
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(cardsProvider(widget.deck.id));
    final cardCount = cardsAsync.value?.length ?? 0;
    final currentIndex = cardCount == 0
        ? 0
        : _cardIndex.clamp(0, cardCount - 1);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.name), centerTitle: true),

      body: cardsAsync.when(
        data: (cards) {
          // ? i dont think we need this
          // ? since we ensure that there is no empty deck
          // ? upon creation
          // if (cards.isEmpty) {
          //   return Center(
          //     child: Column(
          //       mainAxisSize: .min,
          //       spacing: 12,
          //       children: [
          //         Icon(
          //           context.icons.style,
          //           size: 56,
          //           color: colorScheme.outlineVariant,
          //         ),
          //         Text('No cards', style: theme.textTheme.titleMedium),
          //       ],
          //     ),
          //   );
          // }

          final card = cards[currentIndex];

          return Padding(
            padding: .fromLTRB(screenMargin, 8, screenMargin, 0),
            child: Column(
              children: [
                ProgressBar(
                  currentIndex: currentIndex,
                  cardCount: cards.length,
                ),
                Expanded(
                  child: FlashcardView(
                    key: ValueKey(card.id),
                    frontImage: card.frontImage,
                    frontText: card.frontText,
                    backImage: card.backImage,
                    backText: card.backText,
                  ),
                ),
              ],
            ),
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),

      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: SafeArea(
          child: Padding(
            padding: .all(screenMargin),
            child: Row(
              spacing: 12,
              children: [
                _actionButton(
                  colorScheme,
                  currentIndex > 0 ? () => _move(-1, cardCount) : null,
                  'Previous',
                  context.icons.arrowBack,
                ),
                _actionButton(
                  colorScheme,
                  currentIndex + 1 < cardCount
                      ? () => _move(1, cardCount)
                      : null,
                  'Next',
                  context.icons.arrowForward,
                  iconAlignment: .end,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    ColorScheme colorScheme,
    Function()? onPressed,
    String label,
    IconData icon, {
    IconAlignment? iconAlignment,
  }) => Expanded(
    child: OutlinedButton.icon(
      onPressed: onPressed,
      label: Text(label),
      icon: Icon(icon),
      iconAlignment: iconAlignment,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      ),
    ),
  );
}
