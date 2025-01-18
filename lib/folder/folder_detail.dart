import 'dart:math';

import 'package:flutter/material.dart';
import 'package:karteikarten_app_new/folder/create_folder_from_file.dart';
import 'package:karteikarten_app_new/learning_methods/learning_model_test.dart';
import 'package:provider/provider.dart';
import '../authorization/auth_service.dart';
import '../flashcard/flashcard_model.dart';
import '../flashcard/flashcard_search.dart';
import '../learning_methods/learning_model_type_in.dart';
import 'folder_model.dart';
import '../flashcard/edit_flashcard_dialog.dart';
import '../flashcard/create_flashcard_dialog.dart';
import '../learning_methods/learning_model_flashcards.dart';

class FolderDetail extends StatefulWidget {
  final Folder folder;
  final String userId;

  const FolderDetail({super.key, required this.folder, required this.userId});

  @override
  _FolderDetailState createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> {
  List<Flashcard> selectedFlashcards = [];
  String sortOrder = 'Name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: <Widget>[
          if (selectedFlashcards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                for (var flashcard in selectedFlashcards) {
                  await Provider.of<FolderModel>(context, listen: false)
                      .deleteFlashcard(widget.userId, widget.folder.id, flashcard.id.toString());
                }
                setState(() {
                  selectedFlashcards.clear();
                });
              },
            ),
/*          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                sortOrder = value;
                Provider.of<FolderModel>(context, listen: true).sortFlashcards(widget.folder, sortOrder);
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'question',
                child: Text('Sort by Question'),
              ),
              const PopupMenuItem<String>(
                value: 'answer',
                child: Text('Sort by Answer'),
              ),
            ],
          ),*/
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: FlashcardSearch(widget.folder.flashcards, widget.folder, widget.userId));
            },
          ),
        ],
      ),
      body: Consumer<FolderModel>(
        builder: (context, model, child) {
          model.loadFolders(widget.userId);
          Folder? updatedFolder;

          try {
            updatedFolder = model.folders.firstWhere((f) => f.id == widget.folder.id);
          } catch (e) {
            updatedFolder = null;
          }

          if (updatedFolder == null) {
            return const Center(child: Text('Folder not found.'));
          }

          return ListView.builder(
            itemCount: updatedFolder.flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = updatedFolder!.flashcards[index];
              final isSelected = selectedFlashcards.indexWhere((card) => card.id == flashcard.id) != -1;

              return ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (bool? newValue) {
                    setState(() {
                      final index = selectedFlashcards.indexWhere((card) => card.id == flashcard.id);
                      if (newValue == true && index == -1) {
                        selectedFlashcards.add(flashcard);
                      } else if (newValue == false && index != -1) {
                        selectedFlashcards.removeAt(index);
                      }
                    });
                  },
                ),
                title: Text(flashcard.question),
                subtitle: Text(flashcard.answer),
/*                onLongPress: () {
                  setState(() {
                    if (selectedFlashcards.contains(flashcard)) {
                      selectedFlashcards.remove(flashcard);
                    } else {
                      selectedFlashcards.add(flashcard);
                    }
                  });
                },*/
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(flashcard.question),
                        content: Text(flashcard.answer),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return EditFlashcardDialog(
                              userId: widget.userId,
                              folder: widget.folder,
                              flashcard: flashcard,
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
                                    await Provider.of<FolderModel>(context, listen: false)
                                        .deleteFlashcard(widget.userId, widget.folder.id, flashcard.id.toString());
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
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.note_add),
                        title: const Text('Create Flashcard'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              widget.folder.learnedDate = DateTime.now();
                              return CreateFlashcardDialog(userId: widget.userId, folder: widget.folder);
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.note),
                        title: const Text('learn with flashcards'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              print(widget.folder.learnedDate);
                              widget.folder.learnedDate = DateTime.now();
                              print(widget.folder.learnedDate);
                              return LearningMode(flashcards: widget.folder.flashcards);
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.notes),
                        title: const Text('learn by typing in the answer'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              widget.folder.learnedDate = DateTime.now();
                              return LearningModeTypeIn(flashcards: widget.folder.flashcards);
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.question_answer),
                        title: const Text('prove your knowledge with a test'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final TextEditingController numberController = TextEditingController();
                              int? numberOfQuestions = 0;
                              int numberOfCards = widget.folder.flashcards.length;
                              return AlertDialog(
                                title: const Text('Set Number of Questions'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Please enter the number of questions for your test:'),
                                    TextField(
                                      controller: numberController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter a number',
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
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
                                    child: const Text('Start Test'),
                                    onPressed: () {
                                      // Eingabe validieren
                                      if (numberController.text.length == 0 ||
                                          int.tryParse(numberController.text) == null ||
                                          int.tryParse(numberController.text)! > widget.folder.flashcards.length ||
                                          int.tryParse(numberController.text)! < 1) {
                                        // Fehlerdialog anzeigen, wenn die Eingabe keine gültige Zahl ist
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Error'),
                                              content: const Text("Please enter a valid number between 1 and the number of flashcards in the folder."),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(); // Dialog schließen
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        numberOfQuestions = int.tryParse(numberController.text);
                                        // Eingabe ist gültig, numberOfQuestions setzen
                                        // Optional: Logik hier einfügen, um den Test zu starten
                                        Navigator.of(context).pop(); // Schließt den Dialog
                                        List<Flashcard> cardsToLearn = [];
                                        // Generate the flashcards for the test
                                        while (cardsToLearn.length < numberOfQuestions!) {
                                          cardsToLearn.add(widget.folder.flashcards[
                                          Random().nextInt(widget.folder.flashcards.length)]);
                                        }
                                        Navigator.of(context).pop(); // Close the dialog
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LearningModelTest(flashcards: cardsToLearn),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      ListTile(
                        enabled: false,
                        leading: const Icon(Icons.people_alt_rounded),
                        title: const Text('learn with friends'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return LearningModeTypeIn(flashcards: widget.folder.flashcards);
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.file_upload),
                        title: const Text('Import flashcards from file'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CreateFolderFromFile(userId: widget.userId, folder: widget.folder);
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.file_download),
                        title: const Text('Export folder as txt file'),
                        onTap: () {
                          Navigator.pop(context);
                          Provider.of<FolderModel>(context, listen: false).exportFolder(widget.folder);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Add',
            child: const Icon(Icons.add),
          )
      ),
    );
  }
}