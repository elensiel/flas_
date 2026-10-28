import 'package:flas_/data/deck.dart';
import 'package:flas_/data/flashcard.dart';
import 'package:flutter/material.dart';

class CardEntry {
  final termController = TextEditingController();
  final definitionController = TextEditingController();

  void swap() {
    final temp = termController.text;
    termController.text = definitionController.text;
    definitionController.text = temp;
  }

  void dispose() {
    termController.dispose();
    definitionController.dispose();
  }
}

class DeckBuilderModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final List<CardEntry> cards = [CardEntry()];

  void addCard() {
    cards.add(CardEntry());
    notifyListeners();
  }

  void removeCard(CardEntry card) {
    cards.remove(card);
    notifyListeners();

    // dispose after the frame, since the widget is still mounted until then
    WidgetsBinding.instance.addPostFrameCallback((_) => card.dispose());
  }

  void moveCard(int oldIndex, int newIndex) {
    final card = cards.removeAt(oldIndex);
    cards.insert(newIndex, card);
    notifyListeners();
  }

  void create() {
    if (cards.isEmpty || !formKey.currentState!.validate()) return;

    final deck = Deck(
      title: nameController.text.trim(),
      description: descriptionController.text.trim(),
      cards: cards
          .map(
            (entry) => Flashcard(
              front: entry.termController.text.trim(),
              back: entry.definitionController.text.trim(),
            ),
          )
          .toList(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    for (final c in cards) {
      c.dispose();
    }
    super.dispose();
  }
}
