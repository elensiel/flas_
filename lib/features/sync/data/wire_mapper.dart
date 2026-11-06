import 'package:flas_/core/database/app_db.dart';

class WireMapper {
  const WireMapper._();

  Map<String, Object?> deckToWire(Deck d) => d.toJson()..remove('dirty');

  Map<String, Object?> cardToWire(Flashcard c) => c.toJson()..remove('dirty');

  Deck deckFromWire(Map<String, Object?> j) =>
      Deck.fromJson({...j, 'dirty': false});

  Flashcard cardFromWire(Map<String, Object?> j) =>
      Flashcard.fromJson({...j, 'dirty': false});
}
