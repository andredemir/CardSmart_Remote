import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'folder_model.dart';

class AddFolder extends StatefulWidget {
  final String userId;

  const AddFolder({super.key, required this.userId});

  @override
  _AddFolderState createState() => _AddFolderState();
}

class _AddFolderState extends State<AddFolder> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Folder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Folder Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a folder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newFolder = Folder(
                      id: '',
                      name: _nameController.text,
                      subfolders: [],
                      flashcards: [],
                      learnedDate: DateTime.now(),
                    );
                    await Provider.of<FolderModel>(context, listen: false)
                        .addFolder(widget.userId, newFolder);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Folder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
