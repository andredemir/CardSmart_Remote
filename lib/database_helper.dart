import 'package:cloud_firestore/cloud_firestore.dart';
import 'folder/folder_model.dart';
import 'flashcard/flashcard_model.dart';

class DatabaseHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Folder> getFolder(String userId, String folderId) async {
    DocumentSnapshot snapshot = await _db.collection('users').doc(userId).collection('folders').doc(folderId).get();
    return Folder.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  Future<void> addFolder(String userId, Folder folder) async {
    await _db.collection('users').doc(userId).collection('folders').add(folder.toMap());
  }

  Future<void> updateFolder(String userId, Folder folder) async {
    await _db.collection('users').doc(userId).collection('folders').doc(folder.id).update(folder.toMap());
  }

  Future<void> deleteFolder(String userId, String folderId) async {
    await _db.collection('users').doc(userId).collection('folders').doc(folderId).delete();
  }

  Future<void> addFlashcardToFolder(String userId, String folderId, Flashcard flashcard) async {
    DocumentReference folderRef = _db.collection('users').doc(userId).collection('folders').doc(folderId);
    await folderRef.update({
      'flashcards': FieldValue.arrayUnion([flashcard.toMap()])
    });
  }

  Future<void> updateFlashcard(String userId, String folderId, Flashcard updatedFlashcard) async {
    DocumentReference folderRef = _db.collection('users').doc(userId).collection('folders').doc(folderId);
    DocumentSnapshot folderSnapshot = await folderRef.get();
    Folder folder = Folder.fromMap(folderSnapshot.data() as Map<String, dynamic>, folderSnapshot.id);

    List<Flashcard> updatedFlashcards = folder.flashcards.map((flashcard) {
      if (flashcard.id == updatedFlashcard.id) {
        return updatedFlashcard;
      }
      return flashcard;
    }).toList();

    folder.flashcards = updatedFlashcards;
    await folderRef.update(folder.toMap());
  }
}