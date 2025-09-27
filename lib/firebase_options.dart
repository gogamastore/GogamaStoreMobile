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
          'DefaultFirebaseOptions have not been configured for windows - ',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - ',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCuA_um2SXaPXbEcpn3yvW_mvTdwUFnHXQ',
    appId: '1:954515661623:web:f6e7347d17d6e2ba2ef0b2',
    messagingSenderId: '954515661623',
    projectId: 'orderflow-r7jsk',
    authDomain: 'orderflow-r7jsk.firebaseapp.com',
    databaseURL: 'https://orderflow-r7jsk-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'orderflow-r7jsk.firebasestorage.app',
    measurementId: 'G-9ESEJ1NPX7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUU71TYtfCIqTKwj1SHlbVhqqgbfEHx6U',
    appId: '1:954515661623:android:b8d6000e0456b43c2ef0b2',
    messagingSenderId: '954515661623',
    projectId: 'orderflow-r7jsk',
    databaseURL: 'https://orderflow-r7jsk-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'orderflow-r7jsk.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCv8M05daKu55b075KK7S5Xbctql-E822c',
    appId: '1:954515661623:ios:233c9e6780b0fcc82ef0b2',
    messagingSenderId: '954515661623',
    projectId: 'orderflow-r7jsk',
    databaseURL: 'https://orderflow-r7jsk-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'orderflow-r7jsk.firebasestorage.app',
    androidClientId: '954515661623-28vs65k4jepc3he72lioslf13r9aaqjt.apps.googleusercontent.com',
    iosClientId: '954515661623-p92qcvi8q1a3u8ko4hbvq8v3k8f4nuoe.apps.googleusercontent.com',
    iosBundleId: 'store.gogama.app',
  );

   static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCv8M05daKu55b075KK7S5Xbctql-E822c',
    appId: '1:954515661623:ios:233c9e6780b0fcc82ef0b2',
    messagingSenderId: '954515661623',
    projectId: 'orderflow-r7jsk',
    storageBucket: 'orderflow-r7jsk.appspot.com',
    iosClientId: '954515661623-p92qcvi8q1a3u8ko4hbvq8v3k8f4nuoe.apps.googleusercontent.com',
    iosBundleId: 'store.gogama.app',
  );
}