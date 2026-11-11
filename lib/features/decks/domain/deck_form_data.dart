class CardData {
  const CardData({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.frontImage,
    required this.backImage,
  });

  final String? id;
  final String frontText, backText;
  final String? frontImage, backImage;
}

class DeckFormData {
  const DeckFormData({
    required this.name,
    required this.description,
    required this.cards,
    this.removedCardIds = const {},
  });

  final String name, description;
  final List<CardData> cards;
  final Set<String> removedCardIds;
}
