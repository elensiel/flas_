import 'package:flas_/db/card_side.dart';

class Deck {
  const Deck({
    required this.id,
    required this.title,
    required this.description,
    required this.updatedAt,
    required this.deletedAt,
    required this.dirty,
  });

  final String id;
  final String title;
  final String description;
  final int updatedAt;
  final int? deletedAt;
  final bool dirty;

  Deck copyWith({CardSide? front, CardSide? back, int? position}) => Deck(
    id: id,
    title: title,
    description: description,
    updatedAt: DateTime.now().millisecondsSinceEpoch,
    deletedAt: deletedAt,
    dirty: dirty,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
    'dirty': dirty ? 1 : 0,
  };

  factory Deck.fromMap(Map<String, Object?> m) => Deck(
    id: m['id'] as String,
    title: m['title'] as String,
    description: m['description'] as String,
    updatedAt: m['updated_at'] as int,
    deletedAt: m['deleted_at'] as int?,
    dirty: (m['dirty'] as int) == 1,
  );

  Map<String, Object?> toJson() => toMap()..remove('dirty');

  factory Deck.fromJson(Map<String, Object?> j) =>
      Deck.fromMap({...j, 'dirty': 0});
}
