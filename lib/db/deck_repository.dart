import 'package:drift/drift.dart';
import 'package:flas_/db/app_db.dart';
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

  Future<String> createDeck(String title, String description) async {
    final id = _uuid.v4();
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            title: title,
            description: Value(description),
            updatedAt: _now,
          ),
        );
    return id;
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

  Future<Deck?> readDeck(String id) =>
      (db.select(db.decks)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<List<Flashcard>> readCards(String deckId) =>
      (db.select(db.cards)
            ..where((c) => c.id.equals(deckId) & c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.position)]))
          .get();

  Future<void> updateDeck(String id, {String? title, String? description}) =>
      (db.update(db.decks)..where((d) => d.id.equals(id))).write(
        DecksCompanion(
          title: Value.absentIfNull(title),
          description: Value.absentIfNull(description),
          updatedAt: Value(_now),
          dirty: const Value(true),
        ),
      );

  Future<void> updateCard(
    String id, {
    String? frontText,
    Value<String?> frontImage = const Value.absent(),
    String? backText,
    Value<String?> backImage = const Value.absent(),
    int? position,
  }) => (db.update(db.cards)..where((c) => c.id.equals(id))).write(
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

  Future<void> deleteDeck(String id) => db.transaction(() async {
    final now = _now;
    await (db.update(db.decks)..where((d) => d.id.equals(id))).write(
      DecksCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: Value(true),
      ),
    );
    await (db.update(db.cards)..where((c) => c.deckId.equals(id))).write(
      CardsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: Value(true),
      ),
    );
  });

  Future<void> reorderFlashcards(List<Flashcard> ordered) => db.batch((b) {
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

  Future<List<Deck>> dirtyDecks() =>
      (db.select(db.decks)..where((d) => d.dirty.equals(true))).get();

  Future<List<Flashcard>> dirtyCards() =>
      (db.select(db.cards)..where((c) => c.dirty.equals(true))).get();

  Map<String, Object?> deckToWire(Deck c) => c.toJson()..remove('dirty');
  Map<String, Object?> cardToWire(Flashcard c) => c.toJson()..remove('dirty');

  Deck deckFromWire(Map<String, Object?> j) =>
      Deck.fromJson({...j, 'dirty': false});

  Flashcard cardFromWire(Map<String, Object?> j) =>
      Flashcard.fromJson({...j, 'dirty': false});

  Future<void> markDeckClean(Deck pushed) =>
      (db.update(db.decks)..where(
            (d) =>
                d.id.equals(pushed.id) & d.updatedAt.equals(pushed.updatedAt),
          ))
          .write(const DecksCompanion(dirty: Value(false)));

  Future<void> markCardClean(Flashcard pushed) =>
      (db.update(db.cards)..where(
            (c) =>
                c.id.equals(pushed.id) & c.updatedAt.equals(pushed.updatedAt),
          ))
          .write(const CardsCompanion(dirty: Value(false)));

  Future<void> applyRemoteDeck(Deck remote) async {
    final local = await (db.select(
      db.decks,
    )..where((c) => c.id.equals(remote.id))).getSingleOrNull();
    if (local != null && local.updatedAt > remote.updatedAt) return;
    await db
        .into(db.decks)
        .insertOnConflictUpdate(remote.copyWith(dirty: false));
  }

  Future<void> applyRemoteCard(Flashcard remote) async {
    final local = await (db.select(
      db.cards,
    )..where((c) => c.id.equals(remote.id))).getSingleOrNull();
    if (local != null && local.updatedAt > remote.updatedAt) return;
    await db
        .into(db.cards)
        .insertOnConflictUpdate(remote.copyWith(dirty: false));
  }
}
