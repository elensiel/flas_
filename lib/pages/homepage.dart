import 'package:flas_/common/constants.dart';
import 'package:flas_/db/app_db.dart';
import 'package:flas_/db/providers.dart';
import 'package:flas_/pages/deck_builder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homepage extends ConsumerWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('flas_'),
        actions: [
          IconButton(onPressed: null, icon: Icon(Icons.search)),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DeckBuilderPage(deckId: null)),
            ),
            icon: Icon(Icons.create),
          ),
        ],
      ),

      body: decks.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('No decks yet'))
            : ListView.separated(
                padding: .all(screenMargin),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _DeckTile(deck: list[i]),
              ),
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),

      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.style), label: 'Decks'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}

class _DeckTile extends ConsumerWidget {
  const _DeckTile({required this.deck});
  final Deck deck;

  Future<void> confirmDelete(BuildContext context, WidgetRef ref) async =>
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cardCountProvider(deck.id)).value ?? 0;

    return Container(
      decoration: BoxDecoration(border: .all(), borderRadius: .circular(8)),
      child: ListTile(
        title: Text(
          deck.name,
          style: TextStyle(fontSize: 20, fontWeight: .bold),
        ),
        subtitle: Text(deck.description),
        trailing: Text(
          '$count ${count == 1 ? 'card' : 'cards'}',
          style: TextStyle(fontSize: 16),
        ),
        onTap: () => showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: .min,
              children: [
                ListTile(
                  title: Text('Study'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    //   Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => DeckBuilderPage(deckId: deck.id),
                    //   ),
                    // );
                  },
                ),
                ListTile(
                  title: Text('Edit'),
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
                  title: Text('Delete'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    confirmDelete(context, ref);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
