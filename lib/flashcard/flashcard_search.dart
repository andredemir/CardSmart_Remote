import 'package:flutter/material.dart';
import 'package:karteikarten_app_new/flashcard/edit_flashcard_dialog_for_searchbar.dart';
import 'package:provider/provider.dart';
import 'flashcard_model.dart';
import '../folder/folder_model.dart';

class FlashcardSearch extends SearchDelegate<Flashcard> {
  final List<Flashcard> flashcards;
  final Folder folder;
  final String userId;
  FlashcardSearch(this.flashcards, this.folder, this.userId);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Flashcard(question: '', answer: '', id: ''));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = flashcards.where((flashcard) => flashcard.question.toLowerCase().contains(query.toLowerCase()));

    return ListView(
      children: results.map((flashcard) => ListTile(
        title: Text(flashcard.question),
        subtitle: Text(flashcard.answer),
        onTap: () {
          close(context, flashcard);
        },
      )).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final FolderModel folderModel = Provider.of<FolderModel>(context, listen: false);

    final suggestionList = flashcards.where((flashcard) => flashcard.question.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].question),
          subtitle: Text(suggestionList[index].answer),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EditFlashcardDialogForSearchbar(
                        userId: userId,
                        folder: folder,
                        flashcard: suggestionList[index],
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Flashcard'),
                        content: const Text('Are you sure you want to delete this flashcard?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Delete'),
                            onPressed: () async {
                              await folderModel.deleteFlashcard(userId, folder.id, suggestionList[index].id);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}