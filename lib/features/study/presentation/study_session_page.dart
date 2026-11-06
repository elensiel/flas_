import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/features/decks/providers.dart';
import 'package:flas_/features/study/presentation/flashcard_view.dart';
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
  int index = 0;

  void _move(int delta, int length) {
    final next = index + delta;
    if (next >= 0 && next < length) setState(() => index = next);
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(cardsProvider(widget.deck.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.name), centerTitle: true),

      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) return const Center(child: Text('No cards'));

          final card = cards[index];

          return FlashcardView(
            key: ValueKey(card.id),
            frontImage: card.frontImage,
            frontText: card.frontText,
            backImage: card.backImage,
            backText: card.backText,
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            IconButton(
              onPressed: index > 0
                  ? () => _move(-1, cardsAsync.value?.length ?? 0)
                  : null,
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: index + 1 != cardsAsync.value?.length
                  ? () => _move(1, cardsAsync.value?.length ?? 0)
                  : null,
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
