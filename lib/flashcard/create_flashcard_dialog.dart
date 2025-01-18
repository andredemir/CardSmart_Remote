import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../folder/folder_model.dart';
import 'flashcard_model.dart';

class CreateFlashcardDialog extends StatefulWidget {
  final String userId;
  final Folder folder;

  const CreateFlashcardDialog({super.key, required this.userId, required this.folder});

  @override
  _CreateFlashcardDialogState createState() => _CreateFlashcardDialogState();
}

class _CreateFlashcardDialogState extends State<CreateFlashcardDialog> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Flashcard'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Create'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newFlashcard = Flashcard(
                id: '',
                question: _questionController.text,
                answer: _answerController.text,
              );
              await Provider.of<FolderModel>(context, listen: false)
                  .addFlashcardToFolder(widget.userId, widget.folder.id, newFlashcard);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
