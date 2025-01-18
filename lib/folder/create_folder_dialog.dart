import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'folder_model.dart';

class CreateFolderDialog extends StatefulWidget {
  final String userId;
  final String? parentFolderId; // Optional parent folder ID

  const CreateFolderDialog({super.key, required this.userId, this.parentFolderId});

  @override
  _CreateFolderDialogState createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Folder'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Folder Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a folder name';
            }
            return null;
          },
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
              final newFolder = Folder(
                id: '',
                name: _nameController.text,
                subfolders: [],
                flashcards: [],
                learnedDate: DateTime.now()
              );

              if (widget.parentFolderId == null) {
                await Provider.of<FolderModel>(context, listen: false)
                    .addFolder(widget.userId, newFolder);
              } else {
                await Provider.of<FolderModel>(context, listen: false)
                    .addSubfolder(widget.userId, widget.parentFolderId!, newFolder);
              }

              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
