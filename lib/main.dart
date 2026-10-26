import 'package:flas_/views/pages/deck_review_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(
    //       seedColor: Colors.cyan,
    //       brightness: Brightness.dark,
    //     ),
    //   ),
    //   home: const Scaffold(body: Center(child: Text('hello'))),
    // );

    return DeckReviewPage();
  }
}
