import 'dart:io';

import 'package:crypto/crypto.dart';

class MediaStorage {
  MediaStorage(String root)
    : _root = Directory(root)..createSync(recursive: true);

  final Directory _root;

  static final _validHash = RegExp(r'^[a-f0-9]{64}$');
  static bool isValidHash(String hash) => _validHash.hasMatch(hash);

  File _file(String userId, String hash) => File('${_root.path}/$userId/$hash');

  File? find(String userId, String hash) {
    final f = _file(userId, hash);
    return f.existsSync() ? f : null;
  }

  Future<bool> save(String userId, String hash, Stream<List<int>> data) async {
    final dest = _file(userId, hash);
    if (dest.existsSync()) return true;

    dest.parent.createSync(recursive: true);
    final tmp = File('${dest.path}.tmp');
    try {
      await data.pipe(tmp.openWrite());
      final digest = await sha256.bind(tmp.openRead()).first;
      if (digest.toString() != hash) {
        await tmp.delete();
        return false;
      }
      await tmp.rename(dest.path);
      return false;
    } catch (_) {
      if (tmp.existsSync()) await tmp.delete();
      rethrow;
    }
  }

  Future<void> delete(String userId) async {
    final dir = Directory('${_root.path}/$userId');
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
