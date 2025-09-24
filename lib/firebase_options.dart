// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for your project.
///
/// Use this file when initializing Firebase:
/// ```dart
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAY6PsfhcpbA_qhkDqeY76OL4j5dK_YxiA",
    authDomain: "medora-bb341.firebaseapp.com",
    projectId: "medora-bb341",
    storageBucket: "medora-bb341.firebasestorage.app",
    messagingSenderId: "643095045949",
    appId: "1:643095045949:web:76ae3cb8653c47c1dac754",
    measurementId: "G-FZBMV26LL9",
  );

  // Android config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAY6PsfhcpbA_qhkDqeY76OL4j5dK_YxiA",
    projectId: "medora-bb341",
    storageBucket: "medora-bb341.firebasestorage.app",
    messagingSenderId: "643095045949",
    appId: "1:643095045949:android:8e0eac6154e1c144dac754",
  );

  // iOS config
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyAY6PsfhcpbA_qhkDqeY76OL4j5dK_YxiA",
    projectId: "medora-bb341",
    storageBucket: "medora-bb341.firebasestorage.app",
    messagingSenderId: "643095045949",
    appId: "1:643095045949:ios:fc344b20d3d36877dac754",
    iosBundleId: "com.example.medoraNew",
  );

  // macOS config
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyAY6PsfhcpbA_qhkDqeY76OL4j5dK_YxiA",
    projectId: "medora-bb341",
    storageBucket: "medora-bb341.firebasestorage.app",
    messagingSenderId: "643095045949",
    appId: "1:643095045949:ios:fc344b20d3d36877dac754",
    iosBundleId: "com.example.medoraNew",
  );

  // Windows config
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyAY6PsfhcpbA_qhkDqeY76OL4j5dK_YxiA",
    projectId: "medora-bb341",
    storageBucket: "medora-bb341.firebasestorage.app",
    messagingSenderId: "643095045949",
    appId: "1:643095045949:web:b8ccfa9299bbd472dac754",
  );
}
