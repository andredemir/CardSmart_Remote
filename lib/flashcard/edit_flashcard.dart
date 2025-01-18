import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../folder/folder_model.dart';
import 'flashcard_model.dart';

class EditFlashcard extends StatefulWidget {
  final String userId;
  final String folderId;
  final Flashcard flashcard;

  const EditFlashcard({super.key, required this.userId, required this.folderId, required this.flashcard});

  @override
  _EditFlashcardState createState() => _EditFlashcardState();
}

class _EditFlashcardState extends State<EditFlashcard> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.flashcard.question);
    _answerController = TextEditingController(text: widget.flashcard.answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an answer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedFlashcard = Flashcard(
                      id: widget.flashcard.id,
                      question: _questionController.text,
                      answer: _answerController.text,
                    );
                    Provider.of<FolderModel>(context, listen: false)
                        .updateFlashcard(widget.userId, widget.folderId, updatedFlashcard);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
