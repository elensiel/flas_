import 'package:drift/drift.dart' hide Column;
import 'package:flas_/common/clearable_text_field.dart';
import 'package:flas_/common/constants.dart';
import 'package:flas_/common/image_slot.dart';
import 'package:flas_/db/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardEntry {
  CardEntry({
    this.id,
    String front = '',
    String back = '',
    this.frontImage,
    this.backImage,
  }) : termController = TextEditingController(text: front),
       definitionController = TextEditingController(text: back);

  final String? id;
  final TextEditingController termController;
  final TextEditingController definitionController;
  String? frontImage, backImage;

  void swap() {
    final text = termController.text;
    termController.text = definitionController.text;
    definitionController.text = text;
    final image = frontImage;
    frontImage = backImage;
    backImage = image;
  }

  void dispose() {
    termController.dispose();
    definitionController.dispose();
  }
}

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

    final repo = ref.read(deckRepositoryProvider);
    final deck = await repo.readDeck(widget.deckId!);
    final cards = await repo.readCards(widget.deckId!);

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
      final repo = ref.read(deckRepositoryProvider);
      final deck = await repo.createDeck(
        _name.text.trim(),
        _description.text.trim(),
      );
      for (int i = 0; i < _cards.length; i++) {
        final c = _cards[i];
        await repo.createCard(
          deck,
          position: i,
          frontText: c.termController.text.trim(),
          frontImage: c.frontImage?.trim(),
          backText: c.termController.text.trim(),
          backImage: c.backImage?.trim(),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
  }

  void _update() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final repo = ref.read(deckRepositoryProvider);

      final deck = await repo.readDeck(widget.deckId!);
      final name = _name.text.trim();
      final description = _description.text.trim();
      if (deck?.name != name || deck?.description != description) {
        await repo.updateDeck(
          widget.deckId!,
          name: name,
          description: description,
        );
      }

      final oldCards = await repo.readCards(widget.deckId!);
      for (int i = 0; i < _cards.length; i++) {
        final c = _cards[i];
        final term = c.termController.text.trim();
        final definition = c.definitionController.text.trim();

        if (c.id == null) {
          await repo.createCard(
            widget.deckId!,
            position: i,
            frontText: term,
            frontImage: c.frontImage?.trim(),
            backText: definition,
            backImage: c.backImage?.trim(),
          );
          continue;
        }

        final oldCard = {for (final c in oldCards) c.id: c}[c.id];
        if (oldCard?.position != i ||
            oldCard?.frontText != term ||
            oldCard?.frontImage != c.frontImage ||
            oldCard?.backText != definition ||
            oldCard?.backImage != c.backImage) {
          await repo.updateCard(
            c.id!,
            position: i,
            frontText: term,
            frontImage: Value(c.frontImage), // todo
            backText: definition,
            backImage: Value(c.backImage), // todo
          );
          continue;
        }
      }

      if (_removedCards.isNotEmpty) {
        for (final c in _removedCards) {
          if (c.id != null) await repo.deleteCard(c.id!);
        }
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
        title: Text('Deck Builder'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _saving
                ? null
                : widget.deckId == null
                ? _save
                : _update,
            icon: Icon(Icons.save),
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
              _InfoSection(name: _name, description: _description),
              Divider(thickness: 3),
            ],
          ),

          children: [
            for (int i = 0; i < _cards.length; i++)
              _CardForm(
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
        child: Icon(Icons.add),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.name, required this.description});

  final TextEditingController name;
  final TextEditingController description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(screenMargin),
      child: Column(
        spacing: 8,
        children: [
          ClearableTextField(
            controller: name,
            label: 'Name',
            border: OutlineInputBorder(),
          ),
          ClearableTextField(
            controller: description,
            label: 'Description',
            minLines: 1,
            maxLines: 3,
            border: OutlineInputBorder(),
          ),
        ],
      ),
    );
  }
}

class _CardForm extends StatefulWidget {
  const _CardForm({
    super.key,
    required this.card,
    required this.index,
    required this.onDelete,
  });

  final CardEntry card;
  final int index;
  final VoidCallback onDelete;

  @override
  State<_CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<_CardForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenMargin)
          .copyWith(top: screenMargin),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        controlAffinity: .leading,
        initiallyExpanded: true,
        childrenPadding: .all(16),
        title: Row(
          children: [
            CircleAvatar(child: Text('#${widget.index + 1}')),
            const Spacer(),
            ReorderableDragStartListener(
              index: widget.index,
              child: const Icon(Icons.drag_handle),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'swap':
                widget.card.swap();
                break;
              case 'delete':
                widget.onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'swap',
              child: ListTile(
                leading: Icon(Icons.swap_horiz),
                title: Text('Swap'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
              ),
            ),
          ],
        ),
        children: [
          ImageSlot(
            hash: widget.card.frontImage,
            onChanged: (h) => setState(() => widget.card.frontImage = h),
          ),
          ClearableTextField(
            controller: widget.card.termController,
            label: 'Term',
          ),
          SizedBox(height: 4),
          ImageSlot(
            hash: widget.card.backImage,
            onChanged: (h) => setState(() => widget.card.backImage = h),
          ),
          ClearableTextField(
            controller: widget.card.definitionController,
            label: 'Definition',
          ),
        ],
      ),
    );
  }
}
