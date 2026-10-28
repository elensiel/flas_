import 'package:flutter/material.dart';

const double screenMargin = 16;

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('flas_'),
        actions: [
          // IconButton(onPressed: null, icon: Icon(Icons.settings)),
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.library_add)),
        ],
      ),

      body: SingleChildScrollView(
        padding: .all(screenMargin),
        child: Column(
          spacing: 8,
          children: [
            _RecentsSection(),
            Divider(thickness: 3),
            _DeckListSection(),
          ],
        ),
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

class _RecentsSection extends StatelessWidget {
  const _RecentsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Recents', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: .horizontal,
            itemCount: 20,
            itemBuilder: (context, index) {
              return _deck(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _deck(BuildContext context) => Container(
    padding: .all(8),
    margin: .symmetric(horizontal: 4),
    decoration: BoxDecoration(border: .all(), borderRadius: .circular(8)),
    child: Column(
      children: [
        Text('DECK TITLE HERE', style: Theme.of(context).textTheme.titleMedium),
        Text('# CARDS'),
      ],
    ),
  );
}

class _DeckListSection extends StatelessWidget {
  const _DeckListSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [for (int i = 0; i < 10; i++) _deck(context)],
    );
  }

  Widget _deck(BuildContext context) => Container(
    padding: .all(8),
    decoration: BoxDecoration(border: .all(), borderRadius: .circular(8)),
    alignment: .topStart,
    child: Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Text(
              'DECK TITLE HERE',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Spacer(),
            Text('# CARDS'),
          ],
        ),
        Text(
          'DECK DESCRIPTION HERE',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}
