import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class FlashcardWidget extends StatelessWidget {
  const FlashcardWidget({super.key, required this.front, required this.back});

  final Widget front;
  final Widget back;

  @override
  Widget build(BuildContext context) {
    return FlipCard(front: _side(front), back: _side(back));
  }

  Widget _side(Widget child) => Container(
    padding: EdgeInsets.all(20.0),
    alignment: .center,
    decoration: BoxDecoration(
      color: Colors.blueGrey,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}
