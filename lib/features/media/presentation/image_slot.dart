import 'dart:io';

import 'package:flas_/features/media/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum _ImageAction { library, camera, remove }

class ImageSlot extends ConsumerWidget {
  const ImageSlot({
    super.key,
    required this.hash,
    required this.heroTag,
    required this.onChanged,
  });

  final String? hash;
  final Object heroTag;
  final ValueChanged<String?> onChanged;

  Future<void> _pickFrom(WidgetRef ref, ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked == null) return;

    final hash = await ref.read(mediaStoreProvider).save(File(picked.path));
    onChanged(hash);
  }

  Future<void> _addImage(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    await _pickFrom(ref, source);
  }

  Future<void> _openOverlay(
    BuildContext context,
    WidgetRef ref,
    File file,
  ) async {
    final action = await Navigator.of(context).push<_ImageAction>(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) =>
            _ImageOverlay(file: file, heroTag: heroTag),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case _ImageAction.remove:
        onChanged(null);
      case _ImageAction.library:
        await _pickFrom(ref, ImageSource.gallery);
      case _ImageAction.camera:
        await _pickFrom(ref, ImageSource.camera);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hash == null) {
      return ListTile(
        leading: const Icon(Icons.image),
        title: const Text('Add image'),
        onTap: () => _addImage(context, ref),
        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
      );
    }

    final file = ref.watch(mediaFileProvider(hash!)).value;
    final s = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: file == null ? null : () => _openOverlay(context, ref, file),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: .circular(12),
          child: SizedBox(
            height: 140,
            width: .infinity,
            child: file == null
                ? ColoredBox(color: s.surfaceContainerHigh)
                : Image.file(file, fit: .cover),
          ),
        ),
      ),
    );
  }
}

class _ImageOverlay extends StatelessWidget {
  const _ImageOverlay({required this.file, required this.heroTag});

  final File file;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: .opaque,
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: .blur(sigmaX: 12, sigmaY: 12),
                child: const ColoredBox(color: Colors.black38),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              alignment: .center,
              padding: .all(24),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                spacing: 16,
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: .circular(12),
                      child: Image.file(file, fit: .cover),
                    ),
                  ),
                  Card(
                    margin: .zero,
                    clipBehavior: .antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: .circular(16)),
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Choose from library'),
                          onTap: () =>
                              Navigator.pop(context, _ImageAction.library),
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: const Text('Take photo'),
                          onTap: () =>
                              Navigator.pop(context, _ImageAction.camera),
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: Text(
                            'Remove photo',
                            style: TextStyle(color: s.error),
                          ),
                          onTap: () =>
                              Navigator.pop(context, _ImageAction.remove),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
