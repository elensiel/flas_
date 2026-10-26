import 'package:flas_/data/flashcard.dart';

class Deck {
  const Deck({required this.title, required this.cards});

  final String title;
  final List<Flashcard> cards;
}
