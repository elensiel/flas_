import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/decks/data/deck_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deckRepositoryProvider = Provider(
  (ref) => DeckRepository(db: ref.watch(dbProvider)),
);
