import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/features/decks/domain/deck_form_data.dart';
import 'package:flutter/material.dart';

class CardDraft {
  CardDraft({
    this.id,
    String front = '',
    String back = '',
    this.frontImage,
    this.backImage,
  }) : termController = TextEditingController(text: front),
       definitionController = TextEditingController(text: back);

  final String? id;
  final TextEditingController termController, definitionController;
  String? frontImage, backImage;

  void swap() {
    final text = termController.text;
    termController.text = definitionController.text;
    definitionController.text = text;
    final image = frontImage;
    frontImage = backImage;
    backImage = image;
  }

  void dispose() {
    termController.dispose();
    definitionController.dispose();
  }

  factory CardDraft.fromRow(Flashcard c) => CardDraft(
    id: c.id,
    front: c.frontText,
    back: c.backText,
    frontImage: c.frontImage,
    backImage: c.backImage,
  );

  CardData toData() => CardData(
    id: id,
    frontText: termController.text.trim(),
    backText: definitionController.text.trim(),
    frontImage: frontImage,
    backImage: backImage,
  );
}
