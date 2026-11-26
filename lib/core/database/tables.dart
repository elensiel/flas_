import 'package:drift/drift.dart';

@TableIndex(name: 'idx_decks_dirty', columns: {#dirty})
@DataClassName('Deck')
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@TableIndex(name: 'idx_cards_dirty', columns: {#dirty})
@DataClassName('Flashcard')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text().references(Decks, #id, onDelete: .cascade)();
  IntColumn get position => integer().unique()();
  TextColumn get termText => text().nullable()();
  TextColumn get termImage => text().nullable()();
  TextColumn get definitionText => text().nullable()();
  TextColumn get definitionImage => text().nullable()();
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
