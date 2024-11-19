// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyACp6sOXcS5-8ExHxgaSuKts-3-Jfe0pGs',
    appId: '1:304329472585:web:b10c1f8612cf1f3b0c1d98',
    messagingSenderId: '304329472585',
    projectId: 'wavegetx',
    authDomain: 'wavegetx.firebaseapp.com',
    storageBucket: 'wavegetx.firebasestorage.app',
    measurementId: 'G-J3NGJKR3G1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBz3CXn9lafQiYJKL0TjkWwFtOzonYoaDI',
    appId: '1:304329472585:android:9b47ec3a5bd05dc60c1d98',
    messagingSenderId: '304329472585',
    projectId: 'wavegetx',
    storageBucket: 'wavegetx.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4XAeD6AVCUtuVWGBLKSFkA8eulvDkZ2Q',
    appId: '1:304329472585:ios:ae2b38f89251e8d70c1d98',
    messagingSenderId: '304329472585',
    projectId: 'wavegetx',
    storageBucket: 'wavegetx.firebasestorage.app',
    iosClientId: '304329472585-7j49jgpu3akrab4di6ftk8cc1liiebvv.apps.googleusercontent.com',
    iosBundleId: 'com.wavegetxcliv2.waveGetxCliV2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA4XAeD6AVCUtuVWGBLKSFkA8eulvDkZ2Q',
    appId: '1:304329472585:ios:ae2b38f89251e8d70c1d98',
    messagingSenderId: '304329472585',
    projectId: 'wavegetx',
    storageBucket: 'wavegetx.firebasestorage.app',
    iosClientId: '304329472585-7j49jgpu3akrab4di6ftk8cc1liiebvv.apps.googleusercontent.com',
    iosBundleId: 'com.wavegetxcliv2.waveGetxCliV2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyACp6sOXcS5-8ExHxgaSuKts-3-Jfe0pGs',
    appId: '1:304329472585:web:e12c3da640a8e2db0c1d98',
    messagingSenderId: '304329472585',
    projectId: 'wavegetx',
    authDomain: 'wavegetx.firebaseapp.com',
    storageBucket: 'wavegetx.firebasestorage.app',
    measurementId: 'G-MEEHDT4PDD',
  );
}