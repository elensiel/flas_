import 'package:drift/drift.dart' hide Column;
import 'package:flas_/features/decks/presentation/card_entry.dart';
import 'package:flas_/features/decks/presentation/card_editor.dart';
import 'package:flas_/features/decks/presentation/deck_info_fields.dart';
import 'package:flas_/features/decks/providers.dart';
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
  final _cards = <CardEntry>[];
  final _removedCards = <CardEntry>[];

  bool _loading = true;
  bool _saving = false;
  bool get _isNewDeck => widget.deckId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isNewDeck) {
      _cards.add(CardEntry());
      setState(() => _loading = false);
      return;
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
      _cards.addAll(
        cards.map(
          (c) => CardEntry(
            id: c.id,
            front: c.frontText,
            frontImage: c.frontImage,
            back: c.backText,
            backImage: c.backImage,
          ),
        ),
      );
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final deckRepo = ref.read(deckRepositoryProvider);
      final cardRepo = ref.read(cardRepositoryProvider);

      final deck = await deckRepo.createDeck(
        _name.text.trim(),
        _description.text.trim(),
      );
      for (int i = 0; i < _cards.length; i++) {
        final c = _cards[i];
        await cardRepo.createCard(
          deck,
          position: i,
          frontText: c.termController.text.trim(),
          frontImage: c.frontImage?.trim(),
          backText: c.definitionController.text.trim(),
          backImage: c.backImage?.trim(),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
  }

  Future<void> _update() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final deckRepo = ref.read(deckRepositoryProvider);
      final deck = await deckRepo.readDeck(widget.deckId!);
      final name = _name.text.trim();
      final description = _description.text.trim();
      if (deck?.name != name || deck?.description != description) {
        await deckRepo.updateDeck(
          widget.deckId!,
          name: name,
          description: description,
        );
      }

      final cardRepo = ref.read(cardRepositoryProvider);
      final oldCards = await cardRepo.readCards(widget.deckId!);
      for (int i = 0; i < _cards.length; i++) {
        final c = _cards[i];
        final term = c.termController.text.trim();
        final definition = c.definitionController.text.trim();

        if (c.id == null) {
          await cardRepo.createCard(
            widget.deckId!,
            position: i,
            frontText: term,
            frontImage: c.frontImage?.trim(),
            backText: definition,
            backImage: c.backImage?.trim(),
          );
          continue;
        }

        final oldCardsById = {for (final c in oldCards) c.id: c};
        final oldCard = oldCardsById[c.id];
        if (oldCard?.position != i ||
            oldCard?.frontText != term ||
            oldCard?.frontImage != c.frontImage ||
            oldCard?.backText != definition ||
            oldCard?.backImage != c.backImage) {
          await cardRepo.updateCard(
            c.id!,
            position: i,
            frontText: term,
            frontImage: Value(c.frontImage), // todo
            backText: definition,
            backImage: Value(c.backImage), // todo
          );
        }
      }

      if (_removedCards.isNotEmpty) {
        for (final c in _removedCards) {
          if (c.id != null) await cardRepo.deleteCard(c.id!);
        }
        _removedCards.clear();
      }

      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
  }

  void _addCard() => setState(() => _cards.add(CardEntry()));

  void _moveCard(int oldIndex, int newIndex) =>
      setState(() => _cards.insert(newIndex, _cards.removeAt(oldIndex)));

  void _removeCard(CardEntry c) {
    setState(() {
      _cards.remove(c);
      _removedCards.add(c);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => c.dispose());
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
            onPressed: _saving
                ? null
                : widget.deckId == null
                ? _save
                : _update,
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
