class CardSide {
  const CardSide({required this.text, required this.imageHash});

  final String text;
  final String? imageHash;

  bool get isEmpty => text.trim().isEmpty && imageHash == null;
}
