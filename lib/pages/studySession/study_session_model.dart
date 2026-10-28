import 'package:flas_/data/deck.dart';
import 'package:flas_/data/flashcard.dart';
import 'package:flutter/material.dart';

class StudySessionModel extends ChangeNotifier {
  StudySessionModel({required this.deck});

  final Deck deck;

  int _index = 0;
  int get index => _index;
  Flashcard get currentCard => deck.cards[_index];

  bool get hasPrev => _index > 0;
  bool get hasNext => _index < deck.cards.length - 1;

  void next() {
    if (hasNext) {
      _index++;
      notifyListeners();
    }
  }

  void prev() {
    if (hasPrev) {
      _index--;
      notifyListeners();
    }
  }
}
