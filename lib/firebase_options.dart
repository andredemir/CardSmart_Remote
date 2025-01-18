import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCmd3SgpJooYuvrhlpAK42xdGPVX3YrroE',
      authDomain: 'YOUR_AUTH_DOMAIN',
      projectId: 'karteinkartenapp',
      storageBucket: 'YOUR_STORAGE_BUCKET',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      appId: '1:317436331871:android:7cfea157a59242577118ea',
      measurementId: 'YOUR_MEASUREMENT_ID',
    );
  }
}