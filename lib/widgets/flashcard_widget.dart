import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class FlashcardWidget extends StatelessWidget {
  const FlashcardWidget({super.key, required this.front, required this.back});

  final String front;
  final String back;

  @override
  Widget build(BuildContext context) {
    return FlipCard(front: _side(front), back: _side(back));
  }

  Widget _side(String content) => Padding(
    padding: const EdgeInsets.all(20),
    child: Center(child: Text(content)),
  );
}
