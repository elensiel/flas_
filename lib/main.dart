import 'package:flas_/data/deck.dart';
import 'package:flas_/data/flashcard.dart';
import 'package:flas_/views/pages/study_deck_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: StudyDeckPage(deck: dummyDeck));
  }
}

final dummyDeck = Deck(
  title: 'Flutter Basics',
  cards: const [
    Flashcard(
      front: Text('What is a Widget?'),
      back: Text('The basic building block of a Flutter UI.'),
    ),
    Flashcard(
      front: Text('StatelessWidget vs StatefulWidget?'),
      back: Text(
        'Stateless has no mutable state; Stateful holds state that can change via setState.',
      ),
    ),
    Flashcard(
      front: Text('What does setState do?'),
      back: Text('Marks the widget as dirty and triggers a rebuild.'),
    ),
    Flashcard(
      front: Text('What is BuildContext?'),
      back: Text('A handle to the widget\'s location in the widget tree.'),
    ),
    Flashcard(
      front: Text('What is a Key used for?'),
      back: Text(
        'Preserving state and identity of widgets when the tree changes.',
      ),
    ),
    Flashcard(
      front: Text('What does Expanded do?'),
      back: Text(
        'Makes a child of Row/Column/Flex fill the remaining available space.',
      ),
    ),
  ],
);
