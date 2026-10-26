import 'package:flas_/widgets/flip_card_widget.dart';
import 'package:flutter/material.dart';

class DeckReviewPage extends StatelessWidget {
  const DeckReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(leading: BackButton(), title: Text('DECK TITLE HERE')),

        body: Center(
          child: FlipCardWidget(frontText: 'FRONT', backText: 'BACK'),
        ),

        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: () => {}, icon: Icon(Icons.arrow_back)),
              IconButton(onPressed: () => {}, icon: Icon(Icons.arrow_forward)),
            ],
          ),
        ),
      ),
    );
  }
}
