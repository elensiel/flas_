import 'dart:convert';

import 'package:flas_/features/media/data/media_store.dart';
import 'package:flas_/features/sync/data/sync_local_store.dart';
import 'package:flas_/features/sync/data/wire_mapper.dart';
import 'package:http/http.dart' as http;

class SyncService {
  SyncService({
    required this.store,
    required this.media,
    required this.baseUrl,
    required this.token,
    http.Client? client,
  }) : _http = client ?? http.Client();

  final SyncLocalStore store;
  final MediaStore media;
  final String baseUrl, token;
  final http.Client _http;

  bool _running = false;
  Map<String, String> get _header => {'authorization': 'Bearer $token'};

  Future<void> sync() async {
    if (_running) return;
    _running = true;

    try {
      await _uploadMedia();
      await _push();
      await _pull();
    } finally {
      _running = false;
    }
  }

  Future<void> _uploadMedia() async {
    for (final m in await media.pendingUploads()) {
      final file = await media.file(m.hash);
      if (file == null || !await file.exists()) continue;

      final response = await _http.put(
        Uri.parse('$baseUrl/media/${m.hash}'),
        headers: _header,
        body: await file.readAsBytes(),
      );
      if (response.statusCode == 200) await media.markUploaded(m.hash);
    }
  }

  Future<void> _push() async {
    final decks = await store.dirtyDecks();
    final cards = await store.dirtyCards();
    if (decks.isEmpty && cards.isEmpty) return;

    final response = await _http.post(
      Uri.parse('$baseUrl/sync/push'),
      headers: _header,
      body: jsonEncode({
        'decks': decks.map(WireMapper.deckToWire).toList(),
        'cards': cards.map(WireMapper.cardToWire).toList(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('push failed: ${response.statusCode}');
    }

    for (final d in decks) {
      await store.markDeckClean(d);
    }
    for (final c in cards) {
      await store.markCardClean(c);
    }
  }

  Future<void> _pull() async {
    final since = await store.cursor();
    final response = await _http.get(
      Uri.parse('$baseUrl/sync/pull?since=$since'),
      headers: _header,
    );
    if (response.statusCode != 200) {
      throw Exception('pull failed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    for (final d in body['decks'] as List) {
      await store.applyRemoteDeck(
        WireMapper.deckFromWire(d as Map<String, Object?>),
      );
    }

    for (final c in body['cards'] as List) {
      final card = WireMapper.cardFromWire(c as Map<String, Object?>);
      await _fetchMedia(card.frontImage);
      await _fetchMedia(card.backImage);
      await store.applyRemoteCard(card);
    }
    await store.setCursor(body['cursor'] as int);
  }

  Future<void> _fetchMedia(String? hash) async {
    if (hash == null || await media.file(hash) != null) return;
    final response = await _http.get(
      Uri.parse('$baseUrl/media/$hash'),
      headers: _header,
    );
    if (response.statusCode == 200) {
      await media.saveBytes(hash, response.bodyBytes);
    }
  }
}
