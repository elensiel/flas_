import 'package:flas_/data/deck.dart';
import 'package:flas_/widgets/flashcard_widget.dart';
import 'package:flutter/material.dart';

class StudyDeckPage extends StatefulWidget {
  const StudyDeckPage({super.key, required this.deck});

  final Deck deck;

  @override
  _StudyDeckPageState createState() => _StudyDeckPageState();
}

class _StudyDeckPageState extends State<StudyDeckPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final card = widget.deck.cards[index];

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.deck.title),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlashcardWidget(
          key: ValueKey(index),
          front: card.front,
          back: card.back,
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            _BottomBarButton(icon: Icons.arrow_back, onTap: _prev),
            Text('${index + 1}/${widget.deck.cards.length}'),
            _BottomBarButton(icon: Icons.arrow_forward, onTap: _next),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (index < widget.deck.cards.length - 1) setState(() => index++);
  }

  void _prev() {
    if (index > 0) setState(() => index--);
  }
}

class _BottomBarButton extends StatelessWidget {
  const _BottomBarButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(child: Icon(icon)),
      ),
    );
  }
}
