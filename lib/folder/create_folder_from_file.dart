import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:karteikarten_app_new/folder/folder_model.dart';
import 'package:karteikarten_app_new/flashcard/flashcard_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateFolderFromFile extends StatefulWidget {
  final Folder folder;
  final String userId;

  const CreateFolderFromFile({super.key, required this.folder, required this.userId});

  @override
  _CreateFolderFromFileState createState() => _CreateFolderFromFileState();
}

class _CreateFolderFromFileState extends State<CreateFolderFromFile> {
  Folder? createdFolder;

  Future<void> _pickFile(Folder folder, String userId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'csv', 'json', 'xml', 'html', 'md', 'dart']);

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        setState(() {
          createdFolder = _parseFileContent(content, widget.folder);
        });
        // Get the FolderModel
        FolderModel folderModel = Provider.of<FolderModel>(context, listen: false);
        Set<Flashcard> flashcards = createdFolder!.flashcards.toSet();
        // Add the flashcards to the folder in the FolderModel
        for (Flashcard flashcard in flashcards) {
          folderModel.addFlashcardToFolder(widget.userId, widget.folder.id,  flashcard);
        }
      } else {
        // User canceled the picker
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File picking was canceled')),
        );
      }
    } catch (e) {
      // An error occurred while picking the file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while picking the file: $e')),
      );
    }
  }

  Folder _parseFileContent(String content, Folder currentFolder) {
    var uuid = const Uuid();
    List<Flashcard?> flashcards = content.split('\n').map((line) {
      List<String> parts;
      if (line.contains(':')) {
        parts = line.split(':');
      } else {
        parts = line.split('\t');
      }
      if (parts.length >= 2) {
        String question = parts[0].trim();
        String answer = parts[1].trim();
        Flashcard newFlashcard = Flashcard(id: uuid.v4(), question: question, answer: answer.replaceAll(";", ""));
        // Check if the flashcard is already in the folder
        for (Flashcard existingFlashcard in currentFolder.flashcards) {
          if (existingFlashcard.question == newFlashcard.question && existingFlashcard.answer == newFlashcard.answer) {
            // The flashcard is already in the folder, return null
            return null;
          }
        }
        // The flashcard is not in the folder, return the new flashcard
        return newFlashcard;
      } else {
        return null;
      }
    }).where((flashcard) => flashcard != null).toList();
    flashcards.sort((a, b) => a!.question.compareTo(b!.question));
    // Add the flashcards to the current folder
    for (int i = 0; i < flashcards.length; i++) {
      Flashcard? flashcard = flashcards[i];
      if (flashcard!.question == "null" || flashcard.answer == "null") {
        continue;
      }
      currentFolder.flashcards.add(flashcard);
    }
    return currentFolder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Folder from File"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _pickFile(Folder(id: widget.folder.id, name: 'Current Folder', flashcards: [], subfolders: [], learnedDate: DateTime.now(), ), widget.userId,),
              child: const Text("Import flashcards from File"),
            ),
            if (createdFolder != null)
              Text("Folder '${createdFolder!.name}' created with ${createdFolder!.flashcards.length} flashcards"),
          ],
        ),
      ),
    );
  }
}