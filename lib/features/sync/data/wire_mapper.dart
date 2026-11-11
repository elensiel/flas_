import 'package:flas_/core/database/app_db.dart';

class WireMapper {
  const WireMapper._();

  static Map<String, Object?> deckToWire(Deck d) => d.toJson()..remove('dirty');

  static Map<String, Object?> cardToWire(Flashcard c) =>
      c.toJson()..remove('dirty');

  static Deck deckFromWire(Map<String, Object?> j) =>
      Deck.fromJson({...j, 'dirty': false});

  static Flashcard cardFromWire(Map<String, Object?> j) =>
      Flashcard.fromJson({...j, 'dirty': false});
}
