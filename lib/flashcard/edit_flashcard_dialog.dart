import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../folder/folder_model.dart';
import 'flashcard_model.dart';

class EditFlashcardDialog extends StatefulWidget {
  final String userId;
  final Folder folder;
  final Flashcard flashcard;

  const EditFlashcardDialog({super.key, required this.userId, required this.folder, required this.flashcard});

  @override
  _EditFlashcardDialogState createState() => _EditFlashcardDialogState();
}

class _EditFlashcardDialogState extends State<EditFlashcardDialog> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _questionController.text = widget.flashcard.question;
    _answerController.text = widget.flashcard.answer;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Flashcard'),
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
          child: const Text('Save'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final updatedFlashcard = Flashcard(
                id: widget.flashcard.id,
                question: _questionController.text,
                answer: _answerController.text,
              );
              await Provider.of<FolderModel>(context, listen: false)
                  .updateFlashcard(widget.userId, widget.folder.id, updatedFlashcard);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
