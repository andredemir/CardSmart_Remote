import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../folder/folder_model.dart';

class UpdateFolderDialog extends StatelessWidget {
  final Folder folder;
  final String userId;

  const UpdateFolderDialog({super.key, required this.folder, required this.userId});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: folder.name);

    return AlertDialog(
      title: const Text('Ordnernamen ändern'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Neuer Ordnername'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
            await Provider.of<FolderModel>(context, listen: false)
                .updateFolderName(userId, folder.id, nameController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
