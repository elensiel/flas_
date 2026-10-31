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
            : ListView.builder(
                padding: .all(screenMargin),
                itemCount: list.length,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cardCountProvider(deck.id)).value ?? 0;

    return Dismissible(
      key: ValueKey(deck.id),
      onDismissed: (_) => ref.read(deckRepositoryProvider).deleteDeck(deck.id),
      background: Container(color: Colors.red),
      child: ListTile(
        title: Text(deck.name),
        subtitle: Text(deck.description),
        trailing: Text('$count cards'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DeckBuilderPage(deckId: deck.id)),
        ),
      ),
    );
  }
}
