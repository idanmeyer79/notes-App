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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCzpjGoysNGsh3gANlR00WxKyuyteZJBBw',
    appId: '1:937580516814:ios:fd4a770298a6bd37cac79f',
    messagingSenderId: '937580516814',
    projectId: 'notes-app-f79cc',
    authDomain: 'notes-app-f79cc.firebaseapp.com',
    storageBucket: 'notes-app-f79cc.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDwp8D1yZAM34YuS_iJCL2YwYecGfMwyHE',
    appId: '1:937580516814:android:f5d40c0d32761024cac79f',
    messagingSenderId: '937580516814',
    projectId: 'notes-app-f79cc',
    storageBucket: 'notes-app-f79cc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzpjGoysNGsh3gANlR00WxKyuyteZJBBw',
    appId: '1:937580516814:ios:fd4a770298a6bd37cac79f',
    messagingSenderId: '937580516814',
    projectId: 'notes-app-f79cc',
    storageBucket: 'notes-app-f79cc.firebasestorage.app',
    iosClientId:
        '937580516814-dcb3i77v6u2guurnq57rl79m3tc0m59l.apps.googleusercontent.com',
    iosBundleId: 'com.example.notesApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzpjGoysNGsh3gANlR00WxKyuyteZJBBw',
    appId: '1:937580516814:ios:fd4a770298a6bd37cac79f',
    messagingSenderId: '937580516814',
    projectId: 'notes-app-f79cc',
    storageBucket: 'notes-app-f79cc.firebasestorage.app',
    iosClientId:
        '937580516814-dcb3i77v6u2guurnq57rl79m3tc0m59l.apps.googleusercontent.com',
    iosBundleId: 'com.example.notesApp',
  );
}
