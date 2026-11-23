import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Pre-configured from `firebase-applet-config.json`.
/// Run `flutterfire configure --project=gen-lang-client-0440786332` to add native iOS/Android app IDs.
class DefaultFirebaseOptions {
  static const String firestoreDatabaseId =
      'ai-studio-803e4a0a-f3df-4f3d-b652-d7c9fd5489c6';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3DDbtXMLPcNrdm_Oqqhb3zxvZT26z28k',
    appId: '1:179719911847:web:f229d9801e0aab67155e82',
    messagingSenderId: '179719911847',
    projectId: 'gen-lang-client-0440786332',
    authDomain: 'gen-lang-client-0440786332.firebaseapp.com',
    storageBucket: 'gen-lang-client-0440786332.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3DDbtXMLPcNrdm_Oqqhb3zxvZT26z28k',
    appId: '1:179719911847:web:f229d9801e0aab67155e82',
    messagingSenderId: '179719911847',
    projectId: 'gen-lang-client-0440786332',
    storageBucket: 'gen-lang-client-0440786332.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3DDbtXMLPcNrdm_Oqqhb3zxvZT26z28k',
    appId: '1:179719911847:web:f229d9801e0aab67155e82',
    messagingSenderId: '179719911847',
    projectId: 'gen-lang-client-0440786332',
    storageBucket: 'gen-lang-client-0440786332.firebasestorage.app',
    iosBundleId: 'com.craftbridge.softi',
  );
}
