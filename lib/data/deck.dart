import 'package:flas_/data/flashcard.dart';

class Deck {
  const Deck({
    required this.title,
    required this.description,
    required this.cards,
  });

  final String title;
  final String description;
  final List<Flashcard> cards;
}
