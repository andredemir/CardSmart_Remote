import 'package:flutter/material.dart';
import 'package:karteikarten_app_new/folder/update_folder_dialog.dart';
import 'package:provider/provider.dart';
import '../pages/home_page.dart';
import '../pages/profil.dart';
import 'folder_model.dart';
import 'folder_detail.dart';
import 'create_folder_dialog.dart';
import '../flashcard/create_flashcard_dialog.dart';
import '../authorization/auth_service.dart';
import '../pages/login_page.dart';

class FolderList extends StatelessWidget {
  final String userId;
  final Folder? parentFolder;

  const FolderList({super.key, required this.userId, this.parentFolder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parentFolder == null ? 'Your Folders' : parentFolder!.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'logout') {
                AuthService().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<FolderModel>(
        builder: (context, model, child) {
          model.loadFolders(userId); // Reload folders to ensure updated data
          List<Folder> folders = parentFolder == null ? model.folders : parentFolder!.subfolders;
          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                title: Text(folder.name),
                subtitle: Text("Flashcards: ${folder.flashcards.length}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FolderDetail(folder: folder, userId: AuthService().getCurrentUserId()),
                    ),
                  );
                },
                trailing:Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => UpdateFolderDialog(folder: folder, userId: AuthService().getCurrentUserId()),
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
                              title: const Text('Delete Folder'),
                              content: const Text('Are you sure you want to delete this folder?'),
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
                                        .deleteFolder(userId, folder.id);
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'createFolder',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CreateFolderDialog(userId: userId);
                },
              );
            },
            tooltip: 'Create Folder',
            child: const Icon(Icons.create_new_folder),
          ),
          const SizedBox(height: 10),
          if (parentFolder != null)
            FloatingActionButton(
              heroTag: 'createFlashcard',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateFlashcardDialog(userId: userId, folder: parentFolder!);
                  },
                );
              },
              tooltip: 'Create Flashcard',
              child: const Icon(Icons.note_add),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage())
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FolderList(userId: AuthService().currentUser!.uid)),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Profil()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: "Navigate home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Folders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
