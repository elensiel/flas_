import 'dart:io';

import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/media/presentation/image_context_menu.dart';
import 'package:flas_/features/media/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImageField extends ConsumerWidget {
  const ImageField({
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
              leading: Icon(context.icons.photoLibrary),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(context.icons.photoCamera),
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
    final action = await Navigator.of(context).push<ImageAction>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, animation, _) =>
            ImageContextMenu(file: file, heroTag: heroTag),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case ImageAction.remove:
        onChanged(null);
      case ImageAction.library:
        await _pickFrom(ref, ImageSource.gallery);
      case ImageAction.camera:
        await _pickFrom(ref, ImageSource.camera);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hash == null) {
      return ListTile(
        leading: Icon(context.icons.image),
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
