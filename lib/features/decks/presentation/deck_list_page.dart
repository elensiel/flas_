import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/decks/presentation/deck_tile.dart';
import 'package:flas_/features/decks/providers.dart';
import 'package:flas_/features/decks/presentation/deck_builder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeckListPage extends ConsumerWidget {
  const DeckListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('flas_'),
        actions: [
          IconButton(onPressed: null, icon: Icon(context.icons.search)),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DeckBuilderPage(deckId: null)),
            ),
            icon: Icon(context.icons.create),
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
                      context.icons.style,
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
                      icon: Icon(context.icons.add),
                      label: const Text('Create deck'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: .all(screenMargin),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => DeckTile(deck: list[i]),
              ),
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
