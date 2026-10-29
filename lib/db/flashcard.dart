import 'package:flas_/db/card_side.dart';

class Flashcard {
  const Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.position,
    required this.updatedAt,
    required this.deletedAt,
    required this.dirty,
  });

  final String id;
  final String deckId;
  final CardSide front;
  final CardSide back;
  final int position;
  final int updatedAt;
  final int? deletedAt;
  final bool dirty;

  Flashcard copyWith({CardSide? front, CardSide? back, int? position}) =>
      Flashcard(
        id: id,
        deckId: deckId,
        front: front ?? this.front,
        back: back ?? this.back,
        position: position ?? this.position,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        deletedAt: deletedAt,
        dirty: dirty,
      );

  Map<String, Object?> toMap() => {
    'id': id,
    'deck_id': deckId,
    'front_text': front.text,
    'front_image': front.imageHash,
    'back_text': back.text,
    'back_image': back.imageHash,
    'position': position,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
    'dirty': dirty ? 1 : 0,
  };

  factory Flashcard.fromMap(Map<String, Object?> m) => Flashcard(
    id: m['id'] as String,
    deckId: m['deck_id'] as String,
    front: CardSide(
      text: m['front_text'] as String,
      imageHash: m['front_image'] as String,
    ),
    back: CardSide(
      text: m['back_text'] as String,
      imageHash: m['back_image'] as String,
    ),
    position: m['position'] as int,
    updatedAt: m['updated_at'] as int,
    deletedAt: m['deleted_at'] as int?,
    dirty: (m['dirty'] as int) == 1,
  );

  Map<String, Object?> toJson() => toMap()..remove('dirty');

  factory Flashcard.fromJson(Map<String, Object?> j) =>
      Flashcard.fromMap({...j, 'dirty': 0});
}
