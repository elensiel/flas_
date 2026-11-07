import 'dart:io';

import 'package:flas_/core/theme/theme_context.dart';
import 'package:flutter/material.dart';

enum ImageAction { library, camera, remove }

class ImageContextMenu extends StatelessWidget {
  const ImageContextMenu({
    super.key,
    required this.file,
    required this.heroTag,
  });

  final File file;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _Backdrop(),
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
                  _ActionsMenu(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: .opaque,
        onTap: () => Navigator.pop(context),
        child: BackdropFilter(
          filter: .blur(sigmaX: 12, sigmaY: 12),
          child: const ColoredBox(color: Colors.black38),
        ),
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu();

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;

    return Card(
      margin: .zero,
      clipBehavior: .antiAlias,
      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      child: Column(
        mainAxisSize: .min,
        children: [
          _tile(
            context,
            context.icons.photoLibrary,
            'Choose from Library',
            .library,
          ),
          _tile(context, context.icons.photoCamera, 'Take photo', .camera),
          _tile(
            context,
            context.icons.delete,
            'Remove photo',
            .remove,
            color: error,
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    ImageAction action, {
    Color? color,
  }) => ListTile(
    leading: Icon(icon, color: color),
    title: Text(label, style: TextStyle(color: color)),
    onTap: () => Navigator.pop(context, action),
  );
}
