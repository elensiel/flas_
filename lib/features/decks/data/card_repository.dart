import 'package:drift/drift.dart';
import 'package:flas_/core/database/app_db.dart';
import 'package:uuid/uuid.dart';

class CardRepository {
  const CardRepository({required this.db});

  final AppDatabase db;
  static const _uuid = Uuid();
  int get _now => DateTime.now().millisecondsSinceEpoch;

  Stream<List<Flashcard>> watchCards(String deckId) =>
      (db.select(db.cards)
            ..where((c) => c.deckId.equals(deckId) & c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.position)]))
          .watch();

  Stream<int> watchCardCount(String deckId) {
    final count = db.cards.id.count();
    final query = db.selectOnly(db.cards)
      ..addColumns([count])
      ..where(db.cards.deckId.equals(deckId) & db.cards.deletedAt.isNull());
    return query.map((result) => result.read(count)!).watchSingle();
  }

  Future<String> createCard(
    String deckId, {
    required int position,
    String frontText = '',
    String? frontImage,
    String backText = '',
    String? backImage,
  }) async {
    final id = _uuid.v4();
    await db
        .into(db.cards)
        .insert(
          CardsCompanion.insert(
            id: id,
            deckId: deckId,
            position: position,
            frontText: Value(frontText),
            frontImage: Value(frontImage),
            backText: Value(backText),
            backImage: Value(backImage),
            updatedAt: _now,
          ),
        );
    return id;
  }

  Future<List<Flashcard>> readCards(String deckId) =>
      (db.select(db.cards)
            ..where((c) => c.deckId.equals(deckId) & c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.position)]))
          .get();

  Future<void> updateCard(
    String id, {
    String? frontText,
    Value<String?> frontImage = const Value.absent(),
    String? backText,
    Value<String?> backImage = const Value.absent(),
    int? position,
  }) =>
      (db.update(
        db.cards,
      )..where((c) => c.id.equals(id) & c.deletedAt.isNull())).write(
        CardsCompanion(
          frontText: Value.absentIfNull(frontText),
          frontImage: frontImage,
          backText: Value.absentIfNull(backText),
          backImage: backImage,
          position: Value.absentIfNull(position),
          updatedAt: Value(_now),
          dirty: const Value(true),
        ),
      );

  Future<void> deleteCard(String id) =>
      (db.update(db.cards)..where((c) => c.id.equals(id))).write(
        CardsCompanion(
          deletedAt: Value(_now),
          updatedAt: Value(_now),
          dirty: const Value(true),
        ),
      );

  Future<void> reorderCards(List<Flashcard> ordered) => db.batch((b) {
    for (int i = 0; i < ordered.length; i++) {
      if (ordered[i].position == i) continue;
      b.update(
        db.cards,
        CardsCompanion(
          position: Value(i),
          updatedAt: Value(_now),
          dirty: const Value(true),
        ),
        where: (c) => c.id.equals(ordered[i].id),
      );
    }
  });
}
