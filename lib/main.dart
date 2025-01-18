import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:karteikarten_app_new/theme_change.dart';
import 'package:provider/provider.dart';
import 'authorization/auth_service.dart';
import 'firebase/firebase_options.dart' as firebase_options_1;
import 'folder/folder_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AppLifecycleState updated to $state');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FolderModel()),
        ChangeNotifierProvider(create: (context) => ThemeChanger(ThemeData.dark())),
      ],
      child: Consumer<ThemeChanger>(
        builder: (context, themeChanger, child) {
          return MaterialApp(
            title: 'CardSmart',
            theme: themeChanger.getTheme(),
            home: AuthService().handleAuthState(),
          );
        },
      ),
    );
  }
}