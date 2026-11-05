import 'package:flas_/db/app_db.dart';
import 'package:flas_/db/providers.dart';
import 'package:flip_card/flip_card.dart';
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

          return _FlashcardWidget(
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

class _FlashcardWidget extends ConsumerWidget {
  const _FlashcardWidget({
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
