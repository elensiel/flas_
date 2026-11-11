import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flas_/core/database/app_db.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MediaStore {
  MediaStore(this.db);

  final AppDatabase db;

  Stream<File?> watchFile(String hash) =>
      (db.select(db.mediaFiles)..where((m) => m.hash.equals(hash)))
          .watchSingleOrNull()
          .map((row) => row != null ? File(row.path) : null);

  Future<String> save(File source) async {
    final bytes = await source.readAsBytes();
    final hash = sha256.convert(bytes).toString();

    final dir = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'media'),
    );
    await dir.create(recursive: true);
    final dest = File(p.join(dir.path, hash));
    if (!await dest.exists()) await dest.writeAsBytes(bytes);

    await db
        .into(db.mediaFiles)
        .insert(
          MediaFilesCompanion.insert(hash: hash, path: dest.path),
          mode: .insertOrIgnore,
        );
    return hash;
  }

  Future<File?> file(String hash) async {
    final row = await (db.select(
      db.mediaFiles,
    )..where((media) => media.hash.equals(hash))).getSingleOrNull();
    return row == null ? null : File(row.path);
  }

  Future<List<MediaFile>> pendingUploads() => (db.select(
    db.mediaFiles,
  )..where((media) => media.uploaded.equals(false))).get();

  Future<void> markUploaded(String hash) =>
      (db.update(db.mediaFiles)..where((media) => media.hash.equals(hash)))
          .write(const MediaFilesCompanion(uploaded: Value(true)));

  Future<void> saveBytes(String hash, List<int> bytes) async {
    final dir = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'media'),
    );
    await dir.create(recursive: true);
    final dest = File(p.join(dir.path, hash));
    await dest.writeAsBytes(bytes);
    await db
        .into(db.mediaFiles)
        .insert(
          MediaFilesCompanion.insert(
            hash: hash,
            path: dest.path,
            uploaded: const Value(true),
          ),
          mode: .insertOrIgnore,
        );
  }
}
