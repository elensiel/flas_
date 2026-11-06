import 'package:flas_/common/constants.dart';
import 'package:flas_/db/app_db.dart';
import 'package:flas_/db/providers.dart';
import 'package:flas_/pages/deck_builder_page.dart';
import 'package:flas_/pages/study_session_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homepage extends ConsumerWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('flas_'),
        actions: [
          const IconButton(onPressed: null, icon: Icon(Icons.search)),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DeckBuilderPage(deckId: null)),
            ),
            icon: const Icon(Icons.create),
          ),
        ],
      ),

      body: decks.when(
        data: (list) => list.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: .min,
                  spacing: 12,
                  children: [
                    Icon(
                      Icons.style,
                      size: 56,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Text(
                      'No decks yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeckBuilderPage(deckId: null),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Create deck'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: .all(screenMargin),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _DeckTile(deck: list[i]),
              ),
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),

      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: 0,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.style), label: 'Decks'),
            NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
          ],
        ),
      ),
    );
  }
}

class _DeckTile extends ConsumerWidget {
  const _DeckTile({required this.deck});
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
                ref.read(deckRepositoryProvider).deleteDeck(deck.id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );

  void _showActions(BuildContext context, WidgetRef ref) {
    final s = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
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
              leading: const Icon(Icons.edit),
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
              leading: Icon(Icons.delete, color: s.error),
              title: Text('Delete', style: TextStyle(color: s.error)),
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
    final count = ref.watch(cardCountProvider(deck.id)).value ?? 0;
    final theme = Theme.of(context);
    final s = theme.colorScheme;

    return Material(
      clipBehavior: .antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: .circular(16),
        side: BorderSide(color: s.outline, width: 1.5),
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
                        color: s.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const .symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: .all(color: s.outlineVariant, width: 1.5),
                  borderRadius: .circular(20),
                ),
                child: Text(
                  '$count ${count == 1 ? 'card' : 'cards'}',
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
