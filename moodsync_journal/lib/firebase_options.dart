// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux is not supported yet.',
        );
      default:
        throw UnsupportedError(
          'Unknown platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjP6pWB_89Ta8jesjnmTxd-a0WfzFWD1Q',
    appId: '1:136553787715:android:dc23ed1cfd95af5214fff6',
    messagingSenderId: '136553787715',
    projectId: 'cins467-s25-f6e8d',
    storageBucket: 'cins467-s25-f6e8d.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAI8oWl4EH_aGuyyBQ0gicj3LJ8xJtGMeI',
    appId: '1:136553787715:web:bf60d6c5e6601fa514fff6',
    messagingSenderId: '136553787715',
    projectId: 'cins467-s25-f6e8d',
    authDomain: 'cins467-s25-f6e8d.firebaseapp.com',
    storageBucket: 'cins467-s25-f6e8d.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCIqWA1HKog54Dj3ENiOUQuwxWPe6K9XqE',
    appId: '1:136553787715:ios:14286f05d493715014fff6',
    messagingSenderId: '136553787715',
    projectId: 'cins467-s25-f6e8d',
    storageBucket: 'cins467-s25-f6e8d.firebasestorage.app',
    iosBundleId: 'com.example.moodsyncJournal',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIqWA1HKog54Dj3ENiOUQuwxWPe6K9XqE',
    appId: '1:136553787715:ios:14286f05d493715014fff6',
    messagingSenderId: '136553787715',
    projectId: 'cins467-s25-f6e8d',
    storageBucket: 'cins467-s25-f6e8d.firebasestorage.app',
    iosBundleId: 'com.example.moodsyncJournal',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAI8oWl4EH_aGuyyBQ0gicj3LJ8xJtGMeI',
    appId: '1:136553787715:web:fe4c110186f6bc9014fff6',
    messagingSenderId: '136553787715',
    projectId: 'cins467-s25-f6e8d',
    authDomain: 'cins467-s25-f6e8d.firebaseapp.com',
    storageBucket: 'cins467-s25-f6e8d.firebasestorage.app',
  );

}