import 'package:flas_/core/database/app_db.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/core/widgets/show_app_modal_bottom_sheet.dart';
import 'package:flas_/features/decks/presentation/deck_builder_page.dart';
import 'package:flas_/features/decks/providers.dart';
import 'package:flas_/features/study/presentation/study_session_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeckTile extends ConsumerWidget {
  const DeckTile({super.key, required this.deck});
  final Deck deck;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async =>
      showAdaptiveDialog(
        context: context,
        builder: (dialogContext) => AlertDialog.adaptive(
          title: const Text('Delete deck?'),
          content: Text('"${deck.name}" and its cards will be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () {
                final service = ref.read(deckSaveServiceProvider);
                Navigator.pop(dialogContext);
                service.delete(deck.id);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );

  void _showActions(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    showAppModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: Icon(context.icons.playArrow),
              title: const Text('Study'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudySessionPage(deck: deck),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(context.icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeckBuilderPage(deckId: deck.id),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(context.icons.delete, color: colors.error),
              title: Text('Delete', style: TextStyle(color: colors.error)),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardCount = ref.watch(cardCountProvider(deck.id)).value ?? 0;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      clipBehavior: .antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: .circular(16),
        side: BorderSide(color: colors.outline, width: 1.5),
      ),
      child: InkWell(
        onTap: () => _showActions(context, ref),
        child: Padding(
          padding: const .all(16),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,
                  children: [
                    Text(
                      deck.name,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: .w600,
                      ),
                    ),
                    Text(
                      deck.description,
                      maxLines: 2,
                      overflow: .ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const .symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: .all(color: colors.outlineVariant, width: 1.5),
                  borderRadius: .circular(20),
                ),
                child: Text(
                  '$cardCount ${cardCount == 1 ? 'card' : 'cards'}',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
