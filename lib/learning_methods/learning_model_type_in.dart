import 'package:flutter/material.dart';
import '../flashcard/flashcard_model.dart';

class LearningModeTypeIn extends StatefulWidget {
  final List<Flashcard> flashcards;
  const LearningModeTypeIn({super.key, required this.flashcards});

  @override
  _LearningModeStateTypeIn createState() => _LearningModeStateTypeIn();
}

class _LearningModeStateTypeIn extends State<LearningModeTypeIn> with SingleTickerProviderStateMixin{
  late Flashcard currentFlashcard;
  String userAnswer = '';
  int currentFlashcardIndex = 0;

  @override
  void initState() {
    super.initState();
    currentFlashcard = widget.flashcards[currentFlashcardIndex];
  }

  void nextFlashcard() {
    if (currentFlashcardIndex < widget.flashcards.length - 1) {
      setState(() {
        currentFlashcardIndex++;
        currentFlashcard = widget.flashcards[currentFlashcardIndex];
      });
    } else {
      // Hier können Sie eine Aktion hinzufügen, wenn der Benutzer alle Flashcards durchgegangen ist
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Finished!'),
            content: const Text('You have reviewed all the flashcards.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  // You can add more actions here, like navigating to another screen
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Restart'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // You can add more actions here, like navigating to another screen
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LearningModeTypeIn(flashcards: widget.flashcards)));
                },
              ),
            ],
          );
        },
      );
    }
  }
  final TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lernmodus'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox.fromSize(size: const Size.fromHeight(250)),
          Text('Frage: ${currentFlashcard.question}'),
          TextField(
            textAlign: TextAlign.center,
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Antwort eingeben',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              setState(() {
                userAnswer = value;
              });
            },
          ),
          SizedBox.fromSize(size: const Size.fromHeight(10)),
          ElevatedButton(
            child: const Text('Überprüfen'),
            onPressed: () {
              if (userAnswer.toLowerCase().replaceAll(" ", "").toString() == currentFlashcard.answer.toLowerCase().replaceAll(" ", "").toString()) {
                // Zeigen Sie ein Bestätigungsdialog an, wenn die Antwort korrekt ist
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Richtig!'),
                      content: const Text('Ihre Antwort ist korrekt.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Weiter'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            nextFlashcard(); // Wechseln Sie zur nächsten Flashcard
                            clearInput();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Zeigen Sie ein Fehlerdialog an, wenn die Antwort falsch ist
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Falsch!'),
                      content: Text('Die richtige Antwort ist: ${currentFlashcard.answer}'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Erneut versuchen'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            clearInput();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
  void clearInput() {
    setState(() {
      userAnswer = '';
      textController.clear(); // Textfeld zurücksetzen
    });
  }
}