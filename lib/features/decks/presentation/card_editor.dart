import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/core/widgets/clearable_text_field.dart';
import 'package:flas_/features/decks/presentation/card_entry.dart';
import 'package:flas_/features/media/presentation/image_field.dart';
import 'package:flutter/material.dart';

class CardEditor extends StatefulWidget {
  const CardEditor({
    super.key,
    required this.card,
    required this.index,
    required this.onDelete,
  });

  final CardEntry card;
  final int index;
  final VoidCallback onDelete;

  @override
  State<CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;

    return Container(
      margin: .only(left: screenMargin, right: screenMargin, top: screenMargin),
      decoration: BoxDecoration(
        color: s.surfaceContainerLow,
        border: .all(color: s.outline, width: 1.5),
        borderRadius: .circular(16),
      ),
      clipBehavior: .antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        controlAffinity: .leading,
        initiallyExpanded: true,
        maintainState: true, // allow validation on collapsed
        childrenPadding: .all(16),
        title: Row(
          children: [
            Text(
              'Card ${widget.index + 1}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            ReorderableDragStartListener(
              index: widget.index,
              child: Icon(context.icons.dragHandle),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(context.icons.moreVert),
          onSelected: (value) {
            switch (value) {
              case 'swap':
                widget.card.swap();
                break;
              case 'delete':
                widget.onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'swap',
              child: ListTile(
                leading: Icon(context.icons.swapHoriz),
                title: const Text('Swap'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(context.icons.delete),
                title: const Text('Delete'),
              ),
            ),
          ],
        ),
        children: [
          Column(
            spacing: 12,
            crossAxisAlignment: .stretch,
            children: [
              ImageField(
                hash: widget.card.frontImage,
                heroTag: (widget.card, 'front'),
                onChanged: (h) => setState(() => widget.card.frontImage = h),
              ),
              _textField(widget.card.termController, 'Term'),
            ],
          ),
          const Padding(padding: .symmetric(vertical: 16), child: Divider()),
          Column(
            spacing: 12,
            crossAxisAlignment: .stretch,
            children: [
              ImageField(
                hash: widget.card.backImage,
                heroTag: (widget.card, 'back'),
                onChanged: (h) => setState(() => widget.card.backImage = h),
              ),
              _textField(widget.card.definitionController, 'Definition'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label) =>
      ClearableTextField(
        controller: controller,
        label: label,
        textAlign: .justify,
        minLines: 1,
        maxLines: 5,
      );
}
