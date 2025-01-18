
import 'package:flutter/material.dart';
import 'package:karteikarten_app_new/learning_methods/learning_model_test_review_mode.dart';

import '../flashcard/flashcard_model.dart';



class LearningModelTest extends StatefulWidget {
  late List<Flashcard> flashcards; // Ensure this is the correct Flashcard class

  LearningModelTest({super.key, required this.flashcards});

  @override
  _LearningModelTypeInTestState createState() => _LearningModelTypeInTestState();
}

class _LearningModelTypeInTestState extends State<LearningModelTest> {
  int currentIndex = 0;
  int correctAnswers = 0;
  String userAnswer = '';
  final answerController = TextEditingController();
  List<Flashcard> incorrectFlashcards = [];

  void nextCard() {
    if (currentIndex < widget.flashcards.length - 1) {
      if (widget.flashcards[currentIndex].answer != userAnswer) {
        incorrectFlashcards.add(widget.flashcards[currentIndex]);
      } else {
        correctAnswers++;
      }
      setState(() {
        currentIndex++;
        userAnswer = '';
        answerController.clear();
      });
    } else {
      if (widget.flashcards[currentIndex].answer.toLowerCase().replaceAll(" ", "") != userAnswer.toLowerCase().replaceAll(" ", "")) {
        incorrectFlashcards.add(widget.flashcards[currentIndex]);
      } else {
        correctAnswers++;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Test Completed'),
            content: Text('Your accuracy is ${correctAnswers / widget.flashcards.length * 100}%'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Restart'),
                onPressed: () {
                  setState(() {
                    currentIndex = 0;
                    correctAnswers = 0;
                    userAnswer = '';
                    answerController.clear();
                    incorrectFlashcards = [];
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Review Incorrect'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearningModelTestReviewMode(flashcards: incorrectFlashcards),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.flashcards.isNotEmpty)
              Text(
                widget.flashcards[currentIndex].question,
                style: const TextStyle(fontSize: 26),
              ),
            TextField(
              controller: answerController,
              textAlign: TextAlign.center,
              onChanged: (value) {
                userAnswer = value;
              },
            ),
            SizedBox.fromSize(size: const Size.fromHeight(10)),
            ElevatedButton(
              onPressed: nextCard,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}