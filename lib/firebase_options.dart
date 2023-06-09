// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
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
    apiKey: 'AIzaSyCJLLBl72mNJR7MxJSsNNIYFCnPEbg2sPY',
    appId: '1:487013607467:web:c6503151cb462373eae26e',
    messagingSenderId: '487013607467',
    projectId: 'solutions-challenge-378715',
    authDomain: 'solutions-challenge-378715.firebaseapp.com',
    storageBucket: 'solutions-challenge-378715.appspot.com',
    measurementId: 'G-CQHWBB77FS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMXIwnTzqe4Cw87q74XN6-Ko7UuyAe_kU',
    appId: '1:487013607467:android:ca734a013251e80beae26e',
    messagingSenderId: '487013607467',
    projectId: 'solutions-challenge-378715',
    storageBucket: 'solutions-challenge-378715.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzvv1sMa0rkpb0Gly3PCmgFui5TBtC4Rw',
    appId: '1:487013607467:ios:b5804fc0d4fcb005eae26e',
    messagingSenderId: '487013607467',
    projectId: 'solutions-challenge-378715',
    storageBucket: 'solutions-challenge-378715.appspot.com',
    iosClientId: '487013607467-gqgpaujbq8uhm5pf7vnqjrcs980u7pk0.apps.googleusercontent.com',
    iosBundleId: 'com.centralians.scha',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBzvv1sMa0rkpb0Gly3PCmgFui5TBtC4Rw',
    appId: '1:487013607467:ios:370b51ae6c1c6b97eae26e',
    messagingSenderId: '487013607467',
    projectId: 'solutions-challenge-378715',
    storageBucket: 'solutions-challenge-378715.appspot.com',
    iosClientId: '487013607467-cmu3qagua95imbjjase50trr2vi1re56.apps.googleusercontent.com',
    iosBundleId: 'com.example.shcaTest',
  );
}
