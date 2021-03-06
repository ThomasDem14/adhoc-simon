// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcsqd9MC-utg9SdLnKl7u7b5h-A9qscdU',
    appId: '1:184521503838:web:23211798c8bc543139b0cf',
    messagingSenderId: '184521503838',
    projectId: 'adhoc-simon',
    authDomain: 'adhoc-simon.firebaseapp.com',
    storageBucket: 'adhoc-simon.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANqtyQQ_pIVN90IXWSjvbLCKOHd2cswIU',
    appId: '1:184521503838:android:b179e208768dd26439b0cf',
    messagingSenderId: '184521503838',
    projectId: 'adhoc-simon',
    storageBucket: 'adhoc-simon.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAr9FJ8dDOPykSdxc1D-FFcCdsm2fpeS_Y',
    appId: '1:184521503838:ios:8fdcd9afa1445f6139b0cf',
    messagingSenderId: '184521503838',
    projectId: 'adhoc-simon',
    storageBucket: 'adhoc-simon.appspot.com',
    iosClientId: '184521503838-57sd5mii8vp3fial3nog053attlufisf.apps.googleusercontent.com',
    iosBundleId: 'ulg.adhoc.simon',
  );
}
