import 'package:drift/drift.dart';
import 'package:flas_/core/database/database.dart';
import 'package:uuid/uuid.dart';

class DeckRepository {
  const DeckRepository({required this.db});

  final AppDatabase db;

  static const _uuid = Uuid();
  int get _now => DateTime.now().millisecondsSinceEpoch;

  Stream<List<Deck>> watchDecks() =>
      (db.select(db.decks)
            ..where((d) => d.deletedAt.isNull())
            ..orderBy([(d) => .desc(d.updatedAt)]))
          .watch();

  Future<String> createDeck(String name, String? description) async {
    final id = _uuid.v4();
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            name: name,
            description: Value(description),
            updatedAt: _now,
          ),
        );
    return id;
  }

  Future<Deck?> readDeck(String id) => (db.select(
    db.decks,
  )..where((d) => d.id.equals(id) & d.deletedAt.isNull())).getSingleOrNull();

  Future<void> updateDeck(String id, String name, String? description) =>
      (db.update(
        db.decks,
      )..where((d) => d.id.equals(id) & d.deletedAt.isNull())).write(
        DecksCompanion(
          name: Value(name),
          description: Value.absentIfNull(description),
          updatedAt: Value(_now),
          dirty: const Value(true),
        ),
      );

  Future<void> deleteDeck(String id) async {
    final now = _now;

    await (db.update(db.decks)..where((d) => d.id.equals(id))).write(
      DecksCompanion(
        updatedAt: Value(now),
        deletedAt: Value(now),
        dirty: const Value(true),
      ),
    );

    await (db.update(
      db.cards,
    )..where((c) => c.deckId.equals(id) & c.deletedAt.isNull())).write(
      CardsCompanion(
        updatedAt: Value(now),
        deletedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }
}
