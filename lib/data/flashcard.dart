import 'package:flutter/material.dart';

/// A data class representing a single flashcard with two sides.
///
/// Each side is a [Widget], so content is not limited to text: images,
/// icons, formatted text, or any composed widget tree can be used.
///
/// Instances are immutable and can be declared `const` when both sides
/// are const widgets.
///
/// Example:
/// ```dart
/// const card = Flashcard(
///   front: Text('Capital of France?'),
///   back: Text('Paris'),
/// );
/// ```
class Flashcard {
  const Flashcard({required this.front, required this.back});

  final Widget front; // prompt or question
  final Widget back; // answer
}
