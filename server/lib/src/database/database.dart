import 'package:sqlite3/sqlite3.dart';

Database openAppDatabase(String path) {
  final db = sqlite3.open('flas_server.db');
  db.execute(_schema);
  return db;
}

const _schema = '''
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;
PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS decks( 
  user_id TEXT NOT NULL,
  id TEXT NOT NULL, 
  name TEXT NOT NULL, 
  description TEXT NOT NULL, 
  updated_at INTEGER NOT NULL, 
  deleted_at INTEGER, 
  seq INTEGER NOT NULL,
  PRIMARY KEY(user_id, id)
);

CREATE TABLE IF NOT EXISTS cards(
  user_id TEXT NOT NULL,
  id TEXT NOT NULL, 
  deck_id TEXT NOT NULL,
  front_text TEXT NOT NULL, 
  front_image TEXT,
  back_text TEXT NOT NULL, 
  back_image TEXT,
  position INTEGER NOT NULL, 
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER, 
  seq INTEGER NOT NULL,
  PRIMARY KEY(user_id, id)
);

CREATE INDEX IF NOT EXISTS idx_decks_seq ON decks(user_id, seq);
CREATE INDEX IF NOT EXISTS idx_cards_seq ON cards(user_id, seq);

CREATE TABLE IF NOT EXISTS meta(
  key TEXT PRIMARY KEY, 
  value INTEGER NOT NULL
);
INSERT OR IGNORE INTO meta VALUES('seq', 0);
''';
