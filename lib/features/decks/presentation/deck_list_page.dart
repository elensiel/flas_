import 'package:flas_/core/constants.dart';
import 'package:flas_/core/theme/theme_context.dart';
import 'package:flas_/features/decks/presentation/deck_builder_page.dart';
import 'package:flas_/features/decks/presentation/deck_tile.dart';
import 'package:flas_/features/decks/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class DeckListPage extends ConsumerStatefulWidget {
  const DeckListPage({super.key});

  @override
  ConsumerState<DeckListPage> createState() => _DeckListPageState();
}

class _DeckListPageState extends ConsumerState<DeckListPage> {
  bool _searching = false;
  final _controller = TextEditingController();

  void _openSearch() => setState(() => _searching = true);

  void _closeSearch() {
    _controller.clear();
    ref.read(deckSearchQueryProvider.notifier).state = '';
    setState(() => _searching = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decks = ref.watch(filteredDecksProvider);
    final hasQuery = ref.watch(deckSearchQueryProvider).isNotEmpty;

    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _searching
              ? IconButton(
                  onPressed: _closeSearch,
                  icon: Icon(context.icons.arrowBack),
                )
              : null,
          title: _searching
              ? Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme(),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: .search,
                    decoration: const InputDecoration(
                      hintText: 'Search decks',
                      border: .none,
                    ),
                    onChanged: (value) =>
                        ref.read(deckSearchQueryProvider.notifier).state =
                            value,
                  ),
                )
              : const Text('flas_'),
          actions: _searching
              ? [
                  if (hasQuery)
                    IconButton(
                      onPressed: () {
                        _controller.clear();
                        ref.read(deckSearchQueryProvider.notifier).state = '';
                      },
                      icon: Icon(context.icons.close),
                    ),
                ]
              : [
                  IconButton(
                    onPressed: _openSearch,
                    icon: Icon(context.icons.search),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeckBuilderPage(deckId: null),
                      ),
                    ),
                    icon: Icon(context.icons.create),
                  ),
                ],
        ),

        body: decks.when(
          data: (list) => list.isEmpty
              ? hasQuery
                    ? const Center(child: Text('No matching decks'))
                    : Center(
                        child: Column(
                          mainAxisSize: .min,
                          spacing: 12,
                          children: [
                            Icon(
                              context.icons.style,
                              size: 56,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                            Text(
                              'No decks yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            FilledButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const DeckBuilderPage(deckId: null),
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
                  itemBuilder: (_, i) => DeckTile(deck: list[i]),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                ),
          error: (e, _) => Center(child: Text('$e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
