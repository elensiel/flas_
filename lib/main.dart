import 'package:flas_/data/deck.dart';
import 'package:flas_/data/flashcard.dart';
import 'package:flas_/pages/homepage/homepage.dart';
import 'package:flas_/pages/studySession/study_session_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // home: DeckBuilderPage(),
      // home: StudySessionPage(deck: dummyDeck),
      home: Homepage(),
    );
  }
}

const dummyDeck = Deck(
  title: 'Flutter Basics',
  description: 'Core Flutter and Dart concepts.',
  cards: [
    Flashcard(
      front: 'What is a Widget?',
      back: 'The basic building block of a Flutter UI.',
    ),
    Flashcard(
      front: 'StatelessWidget vs StatefulWidget?',
      back: 'Stateless has no mutable state; Stateful holds state that can change via setState().',
    ),
    Flashcard(
      front: 'What does build() do?',
      back: 'Describes the widget subtree for the current configuration and state.',
    ),
    Flashcard(
      front: 'What is hot reload?',
      back: 'Injects updated code into the running app while preserving state.',
    ),
    Flashcard(
      front: 'What is a Future in Dart?',
      back: 'An object representing a value or error that will be available later.',
    ),
  ],
);
