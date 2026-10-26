import 'package:flutter/material.dart';

class DeckBuilderPage extends StatefulWidget {
  const DeckBuilderPage({super.key});

  @override
  _DeckBuilderPageState createState() => _DeckBuilderPageState();
}

class _DeckBuilderPageState extends State<DeckBuilderPage> {
  int cardCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Create Deck'),
        actions: [TextButton(onPressed: () {}, child: Text('Create'))],
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            DeckDescriptionForm(),
            Divider(thickness: 2),
            _DeckCardForm(count: cardCount),
          ],
        ),
      ),
    );
  }
}

class DeckDescriptionForm extends StatefulWidget {
  const DeckDescriptionForm({super.key});

  @override
  _DeckDescriptionFormState createState() => _DeckDescriptionFormState();
}

class _DeckDescriptionFormState extends State<DeckDescriptionForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        child: Column(
          spacing: 8,
          children: [
            TextFormField(decoration: InputDecoration(labelText: 'Name')),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckCardForm extends StatefulWidget {
  const _DeckCardForm({required this.count});

  final int count;

  @override
  __DeckCardFormState createState() => __DeckCardFormState();
}

class __DeckCardFormState extends State<_DeckCardForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        for (int i = 0; i < widget.count; i++)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              spacing: 8,
              children: [
                Form(
                  child: Column(
                    spacing: 8,
                    children: [
                      Text('#${i + 1}'),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Term'),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Definition'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
