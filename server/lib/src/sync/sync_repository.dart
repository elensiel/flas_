import 'package:sqlite3/sqlite3.dart';

class PullResult {
  const PullResult({
    required this.decks,
    required this.cards,
    required this.cursor,
  });

  final List<Map<String, Object>> decks, cards;
  final int cursor;

  Map<String, Object> toJson() => {
    'decks': decks,
    'cards': cards,
    'cursor': cursor,
  };
}

class SyncRepository {
  SyncRepository(this._db) {
    _nextSeq = _db.prepare(
      "UPDATE meta SET value = value + 1 WHERE key='seq' RETURNING value",
    );
    _currentSeq = _db.prepare("SELECT value FROM meta WHERE key='seq'");
    _upsertDeck = _db.prepare('''
    INSERT INTO decks(user_id, id, name, description, updated_at, deleted_at, seq)
    VALUES(?,?,?,?,?,?,?)
    ON CONFLICT(user_id, id) DO UPDATE SET
      name=excluded.name,
      description=excluded.description,
      updated_at=excluded.updated_at,
      deleted_at=excluded.deleted_at,
      seq=excluded.seq
    WHERE excluded.updated_at >= decks.updated_at
    ''');
    _upsertCard = _db.prepare('''
    INSERT INTO cards(
      user_id, id, deck_id, front_text, front_image, 
      back_text, back_image, position, 
      updated_at, deleted_at, seq
    )
    VALUES(?,?,?,?,?,?,?,?,?,?,?)
    ON CONFLICT(user_id, id) DO UPDATE SET
      deck_id=excluded.deck_id,
      front_text=excluded.front_text,
      front_image=excluded.front_image,
      back_text=excluded.back_text,
      back_image=excluded.back_image,
      position=excluded.position,
      updated_at=excluded.updated_at,
      deleted_at=excluded.deleted_at,
      seq=excluded.seq
    WHERE excluded.updated_at >= cards.updated_at
    ''');
    _pullDecks = _db.prepare(
      'SELECT * FROM decks WHERE user_id = ? AND seq > ? ORDER BY seq',
    );
    _pullCards = _db.prepare(
      'SELECT * FROM cards WHERE user_id = ? AND seq > ? ORDER BY seq',
    );
  }

  final Database _db;

  late final PreparedStatement _nextSeq,
      _currentSeq,
      _upsertDeck,
      _upsertCard,
      _pullDecks,
      _pullCards;

  int _current() => _currentSeq.select().first['value'] as int;
  int _next() => _nextSeq.select().first['value'] as int;

  void push(
    String userId, {
    required List<Map<String, dynamic>> decks,
    required List<Map<String, dynamic>> cards,
  }) {
    _db.execute('BEGIN');
    try {
      for (final d in decks) {
        _upsertDeck.execute([
          userId,
          d['id'],
          d['name'],
          d['description'],
          d['updatedAt'],
          d['deletedAt'],
          _next(),
        ]);
      }
      for (final c in cards) {
        _upsertCard.execute([
          userId,
          c['id'],
          c['deckId'],
          c['frontText'],
          c['frontImage'],
          c['backText'],
          c['backImage'],
          c['position'],
          c['updatedAt'],
          c['deletedAt'],
          _next(),
        ]);
      }
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  PullResult pull(String userId, int since) {
    final cursor = _current();

    return PullResult(
      decks: [
        for (final d in _pullDecks.select([userId, since]))
          {
            'id': d['id'],
            'name': d['name'],
            'description': d['description'],
            'updatedAt': d['updated_at'],
            'deletedAt': d['deleted_at'],
          },
      ],
      cards: [
        for (final c in _pullCards.select([userId, since]))
          {
            'id': c['id'],
            'deckId': c['deck_id'],
            'frontText': c['front_text'],
            'frontImage': c['front_image'],
            'backText': c['back_text'],
            'backImage': c['back_image'],
            'position': c['position'],
            'updatedAt': c['updated_at'],
            'deletedAt': c['deleted_at'],
          },
      ],
      cursor: cursor,
    );
  }

  void deleteUser(String userId) {
    _db.execute('BEGIN');
    try {
      _db.execute('DELETE FROM cards WHERE user_id = ?', [userId]);
      _db.execute('DELETE FROM decks WHERE user_id = ?', [userId]);
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }
}
