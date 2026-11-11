import 'package:drift/drift.dart' hide Column;
import 'package:flas_/core/database/provider.dart';
import 'package:flas_/features/decks/domain/deck_form_data.dart';
import 'package:flas_/features/decks/presentation/card_draft.dart';
import 'package:flas_/features/decks/presentation/card_editor.dart';
import 'package:flas_/features/decks/presentation/deck_info_fields.dart';
import 'package:flas_/features/decks/providers.dart';
import 'package:flas_/features/sync/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeckBuilderPage extends ConsumerStatefulWidget {
  const DeckBuilderPage({super.key, required this.deckId});

  final String? deckId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeckBuilderPageState();
}

class _DeckBuilderPageState extends ConsumerState<DeckBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _cards = <CardDraft>[];
  final _removedIds = <String>{};

  bool _loading = true;
  bool _saving = false;

  bool get _isNewDeck => widget.deckId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    for (final c in _cards) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (_isNewDeck) {
      _cards.add(CardDraft());
      return setState(() => _loading = false);
    }

    final deck = await ref
        .read(deckRepositoryProvider)
        .readDeck(widget.deckId!);
    final cards = await ref
        .read(cardRepositoryProvider)
        .readCards(widget.deckId!);
    if (!mounted) return;

    setState(() {
      _name.text = deck?.name ?? '';
      _description.text = deck?.description ?? '';
      _cards.addAll(cards.map(CardDraft.fromRow));
      _loading = false;
    });
  }

  DeckFormData _collect() => DeckFormData(
    name: _name.text.trim(),
    description: _description.text.trim(),
    cards: [for (final c in _cards) c.toData()],
    removedCardIds: _removedIds,
  );

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final saveService = ref.read(deckSaveServiceProvider);
      await (_isNewDeck
          ? saveService.create(_collect())
          : saveService.update(widget.deckId!, _collect()));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
  }

  void _addCard() => setState(() => _cards.add(CardDraft()));

  void _moveCard(int oldIndex, int newIndex) =>
      setState(() => _cards.insert(newIndex, _cards.removeAt(oldIndex)));

  void _removeCard(CardDraft c) {
    setState(() {
      _cards.remove(c);
      if (c.id != null) _removedIds.add(c.id!);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => c.dispose());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _saving ? null : _submit,
            icon: const Icon(Icons.save),
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: ReorderableListView(
          onReorderItem: _moveCard,
          buildDefaultDragHandles: true,

          header: Column(
            children: [
              DeckInfoFields(name: _name, description: _description),
              Divider(thickness: 3),
              // Padding(
              //   padding: .symmetric(horizontal: screenMargin),
              //   child: Text(
              //     'Cards',
              //     style: Theme.of(context).textTheme.titleLarge,
              //   ),
              // ),
            ],
          ),

          children: [
            for (int i = 0; i < _cards.length; i++)
              CardEditor(
                key: ObjectKey(_cards[i]),
                card: _cards[i],
                index: i,
                onDelete: () => _removeCard(_cards[i]),
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
