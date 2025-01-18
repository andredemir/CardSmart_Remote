import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:karteikarten_app_new/pages/home_page.dart';
import 'package:provider/provider.dart';
import '../folder/folder_model.dart';
import '../pages/login_page.dart';

class AuthService with ChangeNotifier{
  get currentUser => FirebaseAuth.instance.currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;

  // Handle Auth State
  handleAuthState() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return ChangeNotifierProvider(
            create: (context) => FolderModel()..loadFolders(getCurrentUserId()),
            child: const HomePage(),
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }

  // Sign in with Google
  signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await auth.signInWithCredential(credential);
      await userCredential.user!.updateProfile(displayName: userCredential.user?.email.toString().split("@").first);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
          create: (context) => FolderModel()..loadFolders(userCredential.user!.uid),
          child: const HomePage(),
        )),
      );
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }

  // Sign in with Email and Password
  signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
          create: (context) => FolderModel()..loadFolders(getCurrentUserId()),
          //child: FolderList(userId: userCredential.user!.uid),
          child: const HomePage(),
        )),
      );
    } catch (e) {
      String message = "An error occurred";
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          message = "No user found for that email.";
        } else if (e.code == 'wrong-password') {
          message = "Wrong password provided.";
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Register with Email and Password
  registerWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.updateProfile(displayName: userCredential.user?.email.toString().split("@").first);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      String message = "An error occurred";
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          message = "The password provided is too weak.";
        } else if (e.code == 'email-already-in-use') {
          message = "The account already exists for that email.";
        } else {
          message = e.message ?? message;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
  // Sign out
  signOut() {
    auth.signOut();
  }

  getCurrentUser() {
    return auth.currentUser;
  }

  getCurrentUserId() {
    return auth.currentUser!.uid;
  }
}
