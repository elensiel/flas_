import 'package:drift/drift.dart';
import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/features/decks/data/card_repository.dart';
import 'package:flas_/features/decks/data/deck_repository.dart';
import 'package:flas_/features/decks/domain/deck_form_data.dart';
import 'package:flas_/features/sync/data/sync_service.dart';

class DeckSaveService {
  const DeckSaveService({
    required this.db,
    required this.decks,
    required this.cards,
    required this.syncService,
  });

  final AppDatabase db;
  final DeckRepository decks;
  final CardRepository cards;
  final SyncService syncService;

  Future<void> create(DeckFormData form) async {
    await db.transaction(() async {
      final deckId = await decks.createDeck(form.name, form.description);
      for (int i = 0; i < form.cards.length; i++) {
        await _insert(deckId, i, form.cards[i]);
      }
    });
  }

  Future<void> update(String deckId, DeckFormData form) async {
    await db.transaction(() async {
      final deck = await decks.readDeck(deckId);
      if (deck?.name != form.name || deck?.description != form.description) {
        await decks.updateDeck(
          deckId,
          name: form.name,
          description: form.description,
        );
      }

      final oldCardsById = {
        for (final c in await cards.readCards(deckId)) c.id: c,
      };

      for (int i = 0; i < form.cards.length; i++) {
        final c = form.cards[i];
        if (c.id == null) {
          await _insert(deckId, i, c);
        } else if (_changed(oldCardsById[c.id], c, i)) {
          await cards.updateCard(
            c.id!,
            position: i,
            frontText: c.frontText,
            frontImage: Value(c.frontImage),
            backText: c.backText,
            backImage: Value(c.backImage),
          );
        }
      }

      for (final id in form.removedCardIds) {
        await cards.deleteCard(id);
      }
    });
    syncService.sync();
  }

  Future<void> _insert(String deckId, int position, CardData c) =>
      cards.createCard(
        deckId,
        position: position,
        frontText: c.frontText,
        backText: c.backText,
        frontImage: c.frontImage,
        backImage: c.backImage,
      );

  bool _changed(Flashcard? old, CardData c, int position) =>
      old == null ||
      old.position != position ||
      old.frontText != c.frontText ||
      old.backText != c.backText ||
      old.frontImage != c.frontImage ||
      old.backImage != c.backImage;
}
