import 'package:flutter/material.dart';

class CardEntry {
  CardEntry({
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
}
