import 'dart:io';

import 'package:flas_/db/app_db.dart';
import 'package:flas_/db/deck_repository.dart';
import 'package:flas_/db/media_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deckRepositoryProvider = Provider(
  (ref) => DeckRepository(db: ref.watch(dbProvider)),
);

final mediaStoreProvider = Provider((ref) => MediaStore(ref.watch(dbProvider)));

final decksProvider = StreamProvider<List<Deck>>(
  (ref) => ref.watch(deckRepositoryProvider).watchDecks(),
);

final cardsProvider = StreamProvider.family<List<Flashcard>, String>(
  (ref, deckId) => ref.watch(deckRepositoryProvider).watchCards(deckId),
);

final cardCountProvider = StreamProvider.family<int, String>(
  (ref, deckId) => ref.watch(deckRepositoryProvider).watchCardCount(deckId),
);

final mediaFileProvider = FutureProvider.family<File?, String>(
  (ref, hash) => ref.watch(mediaStoreProvider).file(hash),
);
