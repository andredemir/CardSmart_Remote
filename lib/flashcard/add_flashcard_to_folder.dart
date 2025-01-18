import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../folder/folder_model.dart';
import 'flashcard_model.dart';

class AddFlashcardToFolder extends StatefulWidget {
  final Folder folder;
  final String userId;

  const AddFlashcardToFolder({super.key, required this.folder, required this.userId});

  @override
  _AddFlashcardToFolderState createState() => _AddFlashcardToFolderState();
}

class _AddFlashcardToFolderState extends State<AddFlashcardToFolder> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Flashcard'),
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final flashcard = Flashcard(
                      id: '',
                      question: _questionController.text,
                      answer: _answerController.text,
                    );
                    await Provider.of<FolderModel>(context, listen: false)
                        .addFlashcardToFolder(widget.userId, widget.folder.id, flashcard);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Flashcard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
