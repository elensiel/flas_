import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/core/widgets/app_popup_menu_button.dart';
import 'package:flas_/features/decks/presentation/card_draft.dart';
import 'package:flas_/features/decks/presentation/clearable_text_field.dart';
import 'package:flas_/features/media/presentation/image_field.dart';
import 'package:material_ui/material_ui.dart';

enum _CardAction { swap, delete }

class CardEditor extends StatefulWidget {
  const CardEditor({
    super.key,
    required this.card,
    required this.index,
    required this.onDelete,
  });

  final CardDraft card;
  final int index;
  final VoidCallback onDelete;

  @override
  State<CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  final _termKey = GlobalKey<FormFieldState<String>>();
  final _definitionKey = GlobalKey<FormFieldState<String>>();

  CardDraft get _card => widget.card;

  String? _validateSide(String? text, String? image) {
    final hasText = text?.trim().isNotEmpty ?? false;
    return hasText || image != null ? null : 'Add text or an image';
  }

  void _setImage(
    GlobalKey<FormFieldState<String>> textKey,
    VoidCallback assign,
  ) {
    setState(assign);
    // Clears a stale "Add text or an image" error once an image is added.
    if (textKey.currentState?.hasError ?? false) {
      textKey.currentState!.validate();
    }
  }

  void _onAction(_CardAction action) {
    switch (action) {
      case _CardAction.swap:
        setState(_card.swap);
      case _CardAction.delete:
        widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: .only(left: screenMargin, right: screenMargin, top: screenMargin),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: .all(color: colors.outline, width: 1.5),
        borderRadius: .circular(16),
      ),
      clipBehavior: .antiAlias,
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              'Card ${widget.index + 1}',
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            ReorderableDragStartListener(
              index: widget.index,
              child: Icon(context.icons.dragHandle),
            ),
          ],
        ),
        trailing: AppPopupMenuButton<_CardAction>(
          icon: Icon(context.icons.moreVert),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _CardAction.swap,
              child: ListTile(
                leading: Icon(context.icons.swapHoriz),
                title: const Text('Swap'),
              ),
            ),
            PopupMenuItem(
              value: _CardAction.delete,
              child: ListTile(
                leading: Icon(context.icons.delete),
                title: const Text('Delete'),
              ),
            ),
          ],
          onSelected: _onAction,
        ),
        controlAffinity: .leading,
        initiallyExpanded: true,
        maintainState: true, // Keeps collapsed fields mounted so validation still reaches them.
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: .all(16),
        children: [
          _buildSide(
            label: 'Term',
            heroTag: (_card, 'front'),
            textKey: _termKey,
            controller: _card.termController,
            image: () => _card.frontImage,
            onImageChanged: (hash) =>
                _setImage(_termKey, () => _card.frontImage = hash),
          ),
          const Padding(padding: .symmetric(vertical: 16), child: Divider()),
          _buildSide(
            label: 'Definition',
            heroTag: (_card, 'back'),
            textKey: _definitionKey,
            controller: _card.definitionController,
            image: () => _card.backImage,
            onImageChanged: (hash) =>
                _setImage(_definitionKey, () => _card.backImage = hash),
          ),
        ],
      ),
    );
  }

  Widget _buildSide({
    required String label,
    required Object heroTag,
    required GlobalKey<FormFieldState<String>> textKey,
    required TextEditingController controller,
    required String? Function() image,
    required ValueChanged<String?> onImageChanged,
  }) {
    return Column(
      spacing: 12,
      crossAxisAlignment: .stretch,
      children: [
        ImageField(hash: image(), heroTag: heroTag, onChanged: onImageChanged),
        ClearableTextField(
          controller: controller,
          label: label,
          fieldKey: textKey,
          // Reads the image when validating, not when building, so it is
          // current right after _setImage.
          validator: (value) => _validateSide(value, image()),
          minLines: 1,
          maxLines: 5,
          textAlign: .justify,
        ),
      ],
    );
  }
}
