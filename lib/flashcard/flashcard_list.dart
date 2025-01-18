import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../folder/add_folder.dart';
import '../folder/folder_detail.dart';
import '../folder/folder_model.dart';

class FlashcardList extends StatelessWidget {
  const FlashcardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: Consumer<FolderModel>(
        builder: (context, model, child) {
          return ListView.builder(
            itemCount: model.folders.length,
            itemBuilder: (context, index) {
              final folder = model.folders[index];
              return ListTile(
                title: Text(folder.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FolderDetail(userId: 'someUserId', folder: folder),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFolder(userId: 'someUserId'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}