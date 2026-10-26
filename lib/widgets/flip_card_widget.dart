import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class FlipCardWidget extends StatelessWidget {
  final String frontText;
  final String backText;

  const FlipCardWidget({
    super.key,
    required this.frontText,
    required this.backText,
  });

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      front: TextContainer(text: frontText),
      back: TextContainer(text: backText),
    );
  }
}

class TextContainer extends StatelessWidget {
  final String text;
  final Color backgroundColor;

  const TextContainer({
    super.key,
    required this.text,
    this.backgroundColor = Colors.blueGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: backgroundColor,
      child: Text(text),
    );
  }
}
