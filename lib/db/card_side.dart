import 'package:flas_/db/app_db.dart';

class CardSide {
  const CardSide({required this.text, required this.imageHash});

  final String text;
  final String? imageHash;

  bool get isEmpty => text.trim().isEmpty && imageHash == null;
}

extension FlashcardSides on Flashcard {
  CardSide get front => CardSide(text: frontText, imageHash: frontImage);
  CardSide get back => CardSide(text: backText, imageHash: backImage);
}
