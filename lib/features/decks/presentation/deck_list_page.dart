import 'package:flas_/core/database/dummy_deck.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class DeckListPage extends ConsumerStatefulWidget {
  const DeckListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeckListPageState();
}

class _DeckListPageState extends ConsumerState<DeckListPage> {
  int deckCount = 5;

  final dummyDecks = [
    DummyDeck(title: 'Dummy', subtitle: 'Dummy', cards: 10),
    DummyDeck(title: 'yea', subtitle: 'no', cards: 5),
    DummyDeck(title: 'Test', subtitle: 'Test description', cards: 250),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flas_')),
      body: SafeArea(
        child: ListView.separated(
          padding: .all(16),
          itemCount: dummyDecks.length,
          itemBuilder: (_, int i) => _tile(
            dummyDecks[i].title,
            dummyDecks[i].subtitle,
            dummyDecks[i].cards,
          ),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
        ),
      ),
    );
  }

  Widget _tile(String title, String subtitle, int cardCount) => ListTile(
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: Text('$cardCount'),
  );
}
