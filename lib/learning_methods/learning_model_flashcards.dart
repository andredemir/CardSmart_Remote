import 'dart:math';

import 'package:flutter/material.dart';
import '../flashcard/flashcard_model.dart';

class LearningMode extends StatefulWidget {
  final List<Flashcard> flashcards;

  const LearningMode({super.key, required this.flashcards});

  @override
  _LearningModeState createState() => _LearningModeState();
}

class _LearningModeState extends State<LearningMode> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  bool showAnswer = false;
  late AnimationController _controller;
  late Animation<double> _frontScale;
  late Animation<double> _backScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _frontScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.5),
    ]).animate(_controller);

    _backScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.5),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextCard() {
    if (currentIndex < widget.flashcards.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
      print('Next card clicked');
    }
  }

  void previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
      });
      print('previous card clicked');
    }
  }

  void flipCard() {
    if (_controller.isCompleted || _controller.velocity > 0) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: flipCard,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _backScale,
                    builder: (context, child) => Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(pi * _backScale.value),
                      child: showAnswer ? child : Container(),
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          children: [
                            Text(
                              widget.flashcards[currentIndex].answer,
                              style: const TextStyle(fontSize: 26),
                            ),
                            const Text(
                              'Answer',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _frontScale,
                    builder: (context, child) => Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(pi * (1 - _frontScale.value)),
                      child: showAnswer ? Container() : child,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          children: [
                            Text(
                              widget.flashcards[currentIndex].question,
                              style: const TextStyle(fontSize: 26),
                            ),
                            const Text(
                              'Question',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: previousCard,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: nextCard,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}