import 'package:drift/drift.dart';

@DataClassName('Deck')
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@TableIndex(name: 'idx_cards_deck', columns: {#deckId, #position})
@DataClassName('Flashcard')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get frontText => text().withDefault(const Constant(''))();
  TextColumn get frontImage => text().nullable()();
  TextColumn get backText => text().withDefault(const Constant(''))();
  TextColumn get backImage => text().nullable()();
  IntColumn get position => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DataClassName('MediaFile')
class MediaFiles extends Table {
  TextColumn get hash => text()();
  TextColumn get path => text()();
  BoolColumn get uploaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {hash};
}

class SyncState extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>>? get primaryKey => {key};
}
