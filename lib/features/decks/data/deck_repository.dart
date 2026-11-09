import 'package:drift/drift.dart';
import 'package:flas_/core/database/app_db.dart';
import 'package:uuid/uuid.dart';

class DeckRepository {
  DeckRepository({required this.db});

  final AppDatabase db;

  static const _uuid = Uuid();
  int get _now => DateTime.now().millisecondsSinceEpoch;

  Stream<List<Deck>> watchDecks() =>
      (db.select(db.decks)
            ..where((d) => d.deletedAt.isNull())
            ..orderBy([(d) => OrderingTerm.desc(d.updatedAt)]))
          .watch();

  Future<String> createDeck(String name, String description) async {
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

  Future<void> updateDeck(String id, {String? name, String? description}) =>
      (db.update(
        db.decks,
      )..where((d) => d.id.equals(id) & d.deletedAt.isNull())).write(
        DecksCompanion(
          name: Value.absentIfNull(name),
          description: Value.absentIfNull(description),
          updatedAt: Value(_now),
          dirty: const Value(true),
        ),
      );

  Future<void> deleteDeck(String id) => db.transaction(() async {
    final now = _now;
    await (db.update(db.decks)..where((d) => d.id.equals(id))).write(
      DecksCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: Value(true),
      ),
    );
    await (db.update(
      db.cards,
    )..where((c) => c.deckId.equals(id) & c.deletedAt.isNull())).write(
      CardsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: Value(true),
      ),
    );
  });
}
