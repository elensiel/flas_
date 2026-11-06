import 'package:drift/drift.dart';
import 'package:flas_/core/database/app_db.dart';

class SyncLocalStore {
  const SyncLocalStore({required this.db});

  final AppDatabase db;

  Future<List<Deck>> dirtyDecks() =>
      (db.select(db.decks)..where((d) => d.dirty.equals(true))).get();

  Future<List<Flashcard>> dirtyCards() =>
      (db.select(db.cards)..where((c) => c.dirty.equals(true))).get();

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
