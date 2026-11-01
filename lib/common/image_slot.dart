import 'dart:io';

import 'package:flas_/db/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum _ImageAction { library, camera, remove }

class ImageSlot extends ConsumerWidget {
  const ImageSlot({super.key, required this.hash, required this.onChanged});

  final String? hash;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_ImageAction>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(context, _ImageAction.library),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, _ImageAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove photo'),
              onTap: () => Navigator.pop(context, _ImageAction.remove),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;

    if (action == _ImageAction.remove) {
      onChanged(null);
      return;
    }

    final source = action == _ImageAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked == null) return;

    final hash = await ref.read(mediaStoreProvider).save(File(picked.path));
    onChanged(hash);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hash == null) {
      return ListTile(
        leading: const Icon(Icons.image),
        title: const Text('Add image'),
        onTap: () => _pick(context, ref),
        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
      );
    }

    final file = ref.watch(mediaFileProvider(hash!)).value;
    return Stack(
      alignment: .topRight,
      children: [
        if (file != null)
          ClipRRect(
            borderRadius: .circular(8),
            child: Image.file(file, fit: .cover),
          ),
        IconButton(
          onPressed: () => _pick(context, ref),
          icon: Icon(Icons.add_photo_alternate),
        ),
      ],
    );
  }
}
