import 'package:flas_/pages/deckBuilder/deck_builder_model.dart';
import 'package:flas_/widgets/clearable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*
TODO -- footer space for FAB
? -- hero-like animator for FAB if it reaches the bottom
*/

const double screenMargin = 16;

class DeckBuilderPage extends StatelessWidget {
  const DeckBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeckBuilderModel(),
      child: const _DeckBuilderView(),
    );
  }
}

class _DeckBuilderView extends StatelessWidget {
  const _DeckBuilderView();

  @override
  Widget build(BuildContext context) {
    final model = context.read<DeckBuilderModel>();
    final cards = context.watch<DeckBuilderModel>().cards;

    return Scaffold(
      appBar: AppBar(
        // leading: BackButton(), // were most likely to have this being pushed anyway
        title: const Text('Deck Builder'),
        centerTitle: true,
        actions: [
          TextButton(onPressed: model.create, child: const Text('Create')),
        ],
      ),

      body: Form(
        key: model.formKey,
        child: ReorderableListView(
          onReorderItem: model.moveCard,
          buildDefaultDragHandles: false,

          header: const Column(
            children: [InfoSection(), Divider(thickness: 3)],
          ),

          children: [
            for (int i = 0; i < cards.length; i++)
              CardForm(key: ObjectKey(cards[i]), card: cards[i], index: i),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: model.addCard,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.read<DeckBuilderModel>();

    return Padding(
      padding: const EdgeInsets.all(screenMargin),
      child: Column(
        spacing: 8,
        children: [
          ClearableTextField(
            controller: model.nameController,
            label: 'Name',
            border: OutlineInputBorder(),
          ),
          ClearableTextField(
            controller: model.descriptionController,
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

class CardForm extends StatelessWidget {
  const CardForm({super.key, required this.card, required this.index});

  final CardEntry card;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: screenMargin)
          .copyWith(top: screenMargin),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(child: Text('#${index + 1}')),
              const Spacer(),
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'swap':
                      card.swap();
                      break;
                    case 'delete':
                      context.read<DeckBuilderModel>().removeCard(card);
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
            ],
          ),
          ClearableTextField(controller: card.termController, label: 'Term'),
          ClearableTextField(
            controller: card.definitionController,
            label: 'Definition',
          ),
        ],
      ),
    );
  }
}
