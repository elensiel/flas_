import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/decks/data/card_repository.dart';
import 'package:flas_/features/decks/data/deck_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deckRepositoryProvider = Provider(
  (ref) => DeckRepository(db: ref.watch(dbProvider)),
);

final cardRepositoryProvider = Provider(
  (ref) => CardRepository(db: ref.watch(dbProvider)),
);

final decksProvider = StreamProvider<List<Deck>>(
  (ref) => ref.watch(deckRepositoryProvider).watchDecks(),
);

final cardsProvider = StreamProvider.family<List<Flashcard>, String>(
  (ref, deckId) => ref.watch(cardRepositoryProvider).watchCards(deckId),
);

final cardCountProvider = StreamProvider.family<int, String>(
  (ref, deckId) => ref.watch(cardRepositoryProvider).watchCardCount(deckId),
);
