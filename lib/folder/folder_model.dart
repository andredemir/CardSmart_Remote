import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../flashcard/flashcard_model.dart';
import 'package:permission_handler/permission_handler.dart';

class Folder {
  String id;
  String name;
  List<Folder> subfolders;
  List<Flashcard> flashcards;
  DateTime learnedDate;

  Folder({required this.id, required this.name, required this.subfolders, required this.flashcards,     required this.learnedDate});

  factory Folder.fromMap(Map<String, dynamic> data, String id) {
    List<Folder> subfolders = (data['subfolders'] as List<dynamic>?)
        ?.map((e) => Folder.fromMap(e as Map<String, dynamic>, e['id'] as String? ?? ''))
        .toList() ?? [];

    List<Flashcard> flashcards = (data['flashcards'] as List<dynamic>?)
        ?.map((e) => Flashcard.fromMap(e as Map<String, dynamic>, e['id'] as String? ?? ''))
        .toList() ?? [];

    return Folder(
      id: id,
      name: data['name'] as String? ?? '',
      subfolders: subfolders,
      flashcards: flashcards,
      learnedDate: (data['learnedDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'folders': subfolders.map((e) => e.toMap()).toList(),
      'flashcards': flashcards.map((e) => e.toMap()).toList(),
      'learnedDate': learnedDate,
    };
  }
}

class FolderModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Folder> folders = [];

  void updateLearnedDate(String folderId) {
    Folder? folder = folders.firstWhere((folder) => folder.id == folderId);
    folder.learnedDate = DateTime.now();
    notifyListeners();
  }

  List<Folder> getRecentlyLearnedFolders() {
    List<Folder> recently = List<Folder>.from(folders);
    recently.sort((a, b) => b.learnedDate.compareTo(a.learnedDate));
    return recently.take(4).toList().reversed.toList();
  }

  void addFlashcardsToFolder(String folderId, List<Flashcard> flashcards) {
    // Find the folder or create a new one if it doesn't exist
    Folder folder = folders.firstWhere(
          (folder) => folder.id == folderId,
      orElse: () => Folder(id: folderId, name: 'New Folder', subfolders: [], flashcards: [], learnedDate: DateTime.now()),
    );

    // Add the flashcards to the folder
    folder.flashcards.addAll(flashcards);

    // If the folder was newly created, add it to the folders list
    if (!folders.any((existingFolder) => existingFolder.id == folderId)) {
      folders.add(folder);
    }

    // Notify listeners to update the UI
    notifyListeners();
  }

  Future<void> loadFolders(String userId) async {
    try {
      QuerySnapshot snapshot = await _db.collection('users').doc(userId).collection('folders').get();
      folders = snapshot.docs.map((doc) => Folder.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading folders: $e');
    }
  }
  
  Future<void> addFolder(String userId, Folder folder) async {
    try {
      await _db.collection('users').doc(userId).collection('folders').add(folder.toMap());
      await loadFolders(userId);
      notifyListeners();
    } catch (e) {
      print('Error adding folder: $e');
    }
  }

  Future<void> addSubfolder(String userId, String parentFolderId, Folder subfolder) async {
    try {
      DocumentReference parentFolderRef = _db.collection('users').doc(userId).collection('folders').doc(parentFolderId);
      DocumentSnapshot parentFolderSnapshot = await parentFolderRef.get();
      Folder parentFolder = Folder.fromMap(parentFolderSnapshot.data() as Map<String, dynamic>, parentFolderSnapshot.id);

      parentFolder.subfolders.add(subfolder);
      await parentFolderRef.update(parentFolder.toMap());

      await loadFolders(userId);
      notifyListeners();
    } catch (e) {
      print('Error adding subfolder: $e');
    }
  }

  Future<void> deleteFolder(String userId, String folderId) async {
    try {
      await _db.collection('users').doc(userId).collection('folders').doc(folderId).delete();
      await loadFolders(userId);
      notifyListeners();
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  Future<void> addFlashcardToFolder(String userId, String folderId, Flashcard flashcard) async {
    try {
      if (flashcard.id.isEmpty) {
        flashcard = Flashcard(
          id: generateUniqueId(),
          question: flashcard.question,
          answer: flashcard.answer,
        );
      }

      DocumentReference folderRef = _db.collection('users').doc(userId).collection('folders').doc(folderId);
      await folderRef.update({
        'flashcards': FieldValue.arrayUnion([flashcard.toMap()])
      });
      await loadFolders(userId);
      notifyListeners();
    } catch (e) {
      print('Error adding flashcard to folder: $e');
    }
  }

  Future<void> deleteFlashcards(String userId, String folderId, Set<Flashcard> flashcardsToDelete) async {
    try {
      // Find the folder
      DocumentReference folderRef = _db.collection('users').doc(userId).collection('folders').doc(folderId);
      DocumentSnapshot folderSnapshot = await folderRef.get();
      Folder folder = Folder.fromMap(folderSnapshot.data() as Map<String, dynamic>, folderSnapshot.id);

      // Remove the flashcards from the folder
      List<Flashcard> updatedFlashcards = folder.flashcards.where((flashcard) => !flashcardsToDelete.contains(flashcard)).toList();

      // Update the folder in the database
      await folderRef.update({'flashcards': updatedFlashcards.map((e) => e.toMap()).toList()});

      // Reload folders to ensure updated data
      await loadFolders(userId);

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      print('Error deleting flashcards: $e');
    }
  }

  Future<void> updateFlashcard(String userId, String folderId, Flashcard updatedFlashcard) async {
    try {
      DocumentReference folderRef = _db.collection('users').doc(userId).collection('folders').doc(folderId);
      DocumentSnapshot folderSnapshot = await folderRef.get();
      Folder folder = Folder.fromMap(folderSnapshot.data() as Map<String, dynamic>, folderSnapshot.id);

      // Update the specific flashcard
      List<Flashcard> updatedFlashcards = folder.flashcards.map((flashcard) {
        if (flashcard.id == updatedFlashcard.id) {
          return updatedFlashcard;
        }
        return flashcard;
      }).toList();

      await folderRef.update({'flashcards': updatedFlashcards.map((e) => e.toMap()).toList()});
      await loadFolders(userId);
      notifyListeners();
    } catch (e) {
      print('Error updating flashcard: $e');
    }
  }

  Future<void> exportFolderAsTxt(Folder folder, String filePath) async {
    // Convert the flashcards to the desired format
    String flashcardsData = folder.flashcards
        .map((flashcard) => '${flashcard.question}:${flashcard.answer};\n')
        .join();

    // Create a file and write the data
    final file = File(filePath);
    await file.writeAsString(flashcardsData);
  }

  void exportFolder(Folder folder) async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        return;
      }
    }

    String? directoryPath = await getFilePath();

    if (directoryPath != null) {
      String filePath = '$directoryPath/export_${folder.name}.txt';
      await exportFolderAsTxt(folder, filePath);
    }
  }

  Future<String?> getFilePath() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    return directoryPath;
    }

  Future<void> deleteFlashcard(String userId, String folderId, String flashcardId) async {
    try {
      DocumentReference folderRef = _db.collection('users').doc(userId).collection('folders').doc(folderId);
      DocumentSnapshot folderSnapshot = await folderRef.get();
      Folder folder = Folder.fromMap(folderSnapshot.data() as Map<String, dynamic>, folderSnapshot.id);

      // Remove the specific flashcard
      List<Flashcard> updatedFlashcards = folder.flashcards.where((flashcard) => flashcard.id != flashcardId).toList();

      await folderRef.update({'flashcards': updatedFlashcards.map((e) => e.toMap()).toList()});
      await loadFolders(userId);
      notifyListeners();
    } catch (e) {
      print('Error deleting flashcard: $e');
    }
  }

  Future<void> updateFolderName(String userId, String folderId, String newName) async {
    Folder? folder = folders.firstWhere((folder) => folder.id == folderId);
    folder.name = newName;
    await _db.collection('users').doc(userId).collection('folders').doc(folderId).update({'name': newName});
    notifyListeners();
    }
/*
  void sortFlashcards(Folder folder, String s) {
    if (s == 'question') {
      folder.flashcards.sort((a, b) => a.question.compareTo(b.question));
    } else if (s == 'answer') {
      folder.flashcards.sort((a, b) => a.answer.compareTo(b.answer));
    }
    notifyListeners();
  }*/
}