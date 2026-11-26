import 'package:drift/drift.dart';
import 'package:flas_/core/database/database.dart';
import 'package:uuid/uuid.dart';

class CardRepository {
  const CardRepository({required this.db});

  final AppDatabase db;

  static const _uuid = Uuid();
  int get _now => DateTime.now().millisecondsSinceEpoch;

  Stream<List<Flashcard>> watchCards(String deckId) =>
      (db.select(db.cards)
            ..where((c) => c.deckId.equals(deckId) & c.deletedAt.isNull())
            ..orderBy([(c) => .desc(c.updatedAt)]))
          .watch();

  Future<String> createCard(
    String deckId, {
    required int position,
    String? termText,
    String? termImage,
    String? definitionText,
    String? definitionImage,
  }) async {
    final id = _uuid.v4();
    await db
        .into(db.cards)
        .insert(
          CardsCompanion.insert(
            id: id,
            deckId: deckId,
            position: position,
            termText: Value.absentIfNull(termText),
            termImage: Value.absentIfNull(termImage),
            definitionText: Value.absentIfNull(definitionText),
            definitionImage: Value.absentIfNull(definitionImage),
            updatedAt: _now,
          ),
        );
    return id;
  }

  Future<List<Flashcard>> readCards(String deckId) =>
      (db.select(db.cards)
            ..where((c) => c.deckId.equals(deckId) & c.deletedAt.isNull())
            ..orderBy([(c) => .asc(c.updatedAt)]))
          .get();

  Future<void> updateCard(
    String id, {
    required int position,
    String? termText,
    String? termImage,
    String? definitionText,
    String? definitionImage,
  }) async {
    (db.update(
      db.cards,
    )..where((c) => c.id.equals(id) & c.deletedAt.isNull())).write(
      CardsCompanion(
        position: Value(position),
        termText: Value.absentIfNull(termText),
        termImage: Value.absentIfNull(termImage),
        definitionText: Value.absentIfNull(definitionText),
        definitionImage: Value.absentIfNull(definitionImage),
        updatedAt: Value(_now),
        dirty: const Value(true),
      ),
    );
  }

  Future<void> deleteCard(String id) =>
      (db.update(db.cards)..where((c) => c.id.equals(id))).write(
        CardsCompanion(
          updatedAt: Value(_now),
          deletedAt: Value(_now),
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
