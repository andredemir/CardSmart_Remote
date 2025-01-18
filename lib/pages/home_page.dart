import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karteikarten_app_new/folder/folder_detail.dart';
import 'package:karteikarten_app_new/folder/folder_list.dart';
import 'package:karteikarten_app_new/pages/profil.dart';
import 'package:provider/provider.dart';
import '../authorization/auth_service.dart';
import '../folder/folder_model.dart';
import '../theme_change.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
        appBar: AppBar(
          // Appbar mit Titel und Icons für Theme und Logout
          title: const Text("Home"),
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () {
                // Theme wechselt bei Press
                if (themeChanger.getTheme() == ThemeData.light()) {
                  themeChanger.setTheme(ThemeData.dark());
                } else {
                  themeChanger.setTheme(ThemeData.light());
                }
              },
            ),
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
        body: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(10),
              child: const Text(
                "Recently added folders:",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            Expanded(
              child: Consumer<FolderModel>(
                builder: (context, model, child) {
                  //Alle Ordner vom User speichern
                  model.loadFolders(AuthService().currentUser!.uid);
                  //Ordners in Liste speichern
                  List<Folder> folders = model.folders.toList();
                  //Nach Datum sortieren
                  folders.sort((a, b) => b.learnedDate.compareTo(a.learnedDate));
                  //Nur die ersten 4 Ordner anzeigen
                  folders = folders.toList().take(4).toList();
                  //Liste der Ordner anzeigen
                  return ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];

                      // Verpacke jedes ListTile in einen Card- oder Container-Wrapper für Margin
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Margin
                        child: Card(
                          color: Colors.deepPurple, // Hintergrundfarbe des Cards
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Abgerundete Ecken
                          ),
                          elevation: 10, // Schatteneffekt
                          child: ListTile(
                            title: Text(
                              folder.name,
                              style: const TextStyle(color: Colors.white, fontSize: 18), // Schriftfarbe
                            ),
                            leading: const Icon(Icons.folder, color: Colors.white), // Ordnersymbol
                            subtitle: Text(
                              "Flashcards: ${folder.flashcards.length}",
                              style: const TextStyle(color: Colors.grey, fontSize: 14), // Stil des Untertitels
                            ),
                            // Visuelles Feedback beim Drücken
                            hoverColor: Colors.yellow.withOpacity(0.1),
                            selectedTileColor: Colors.yellow.withOpacity(0.2),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FolderDetail(
                                    folder: folder,
                                    userId: AuthService().currentUser!.uid,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );

                },
            ),
            )],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            unselectedItemColor: Colors.grey,
            iconSize: 30,
            onTap: (int index) {
              if (index == 0) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePage()));
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
            ])
    );
  }
}
