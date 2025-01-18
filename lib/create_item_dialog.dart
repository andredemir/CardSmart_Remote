import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'folder/folder_model.dart';
import 'flashcard/flashcard_model.dart';

class CreateItemDialog extends StatefulWidget {
  final String userId;
  final Folder? parentFolder;

  const CreateItemDialog({super.key, required this.userId, this.parentFolder});

  @override
  _CreateItemDialogState createState() => _CreateItemDialogState();
}

class _CreateItemDialogState extends State<CreateItemDialog> {
  final _nameController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  bool _isCreatingFolder = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isCreatingFolder ? 'Create Folder' : 'Create Flashcard'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          if (!_isCreatingFolder) ...[
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
          ],
          Row(
            children: [
              Checkbox(
                value: _isCreatingFolder,
                onChanged: (bool? value) {
                  setState(() {
                    _isCreatingFolder = value ?? true;
                  });
                },
              ),
              const Text('Create Folder')
            ],
          ),
        ],
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
            if (_isCreatingFolder) {
              final newFolder = Folder(
                id: '',
                name: _nameController.text,
                subfolders: [],
                flashcards: [],
                learnedDate: DateTime.now(),
              );
              await Provider.of<FolderModel>(context, listen: false)
                  .addFolder(widget.userId, newFolder);
            } else {
              final newFlashcard = Flashcard(
                id: '',
                question: _questionController.text,
                answer: _answerController.text,
              );
              if (widget.parentFolder != null) {
                await Provider.of<FolderModel>(context, listen: false)
                    .addFlashcardToFolder(widget.userId, widget.parentFolder!.id, newFlashcard);
              }
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
