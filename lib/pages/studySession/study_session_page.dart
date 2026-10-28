import 'package:flas_/data/deck.dart';
import 'package:flas_/pages/studySession/study_session_model.dart';
import 'package:flas_/widgets/flashcard_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudySessionPage extends StatelessWidget {
  const StudySessionPage({super.key, required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudySessionModel(deck: deck),
      child: const _StudySessionView(),
    );
  }
}

class _StudySessionView extends StatelessWidget {
  const _StudySessionView();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<StudySessionModel>();

    return Scaffold(
      appBar: AppBar(title: Text(model.deck.title), centerTitle: true),

      body: FlashcardWidget(
        key: ValueKey(model.index),
        front: model.currentCard.front,
        back: model.currentCard.back,
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            IconButton(
              onPressed: model.hasPrev ? model.prev : null,
              icon: Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: model.hasNext ? model.next : null,
              icon: Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
