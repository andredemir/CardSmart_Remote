import 'package:flutter/material.dart';
import 'flashcard_model.dart';

class FlashcardDetail extends StatelessWidget {
  final Flashcard flashcard;

  const FlashcardDetail({super.key, required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              flashcard.question,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              flashcard.answer,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}