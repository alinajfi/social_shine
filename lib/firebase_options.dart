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
    apiKey: 'AIzaSyDCojc9UmBh9gutIKv9wYj8VZ20BcGWD-s',
    appId: '1:1004307429297:web:21c5e8a14a93be530aaf90',
    messagingSenderId: '1004307429297',
    projectId: 'akpcircle',
    authDomain: 'akpcircle.firebaseapp.com',
    storageBucket: 'akpcircle.appspot.com',
    measurementId: 'G-1Q4M74GLT6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtddDCYqB4q0bwiglObVKneOO1YcdtmRM',
    appId: '1:1004307429297:android:f9d5e55778d91ca00aaf90',
    messagingSenderId: '1004307429297',
    projectId: 'akpcircle',
    storageBucket: 'akpcircle.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGECgK6hZMGsMA4gbkamMIU5K8MzAA__Y',
    appId: '1:1004307429297:ios:84a3dc5bbfb75ef20aaf90',
    messagingSenderId: '1004307429297',
    projectId: 'akpcircle',
    storageBucket: 'akpcircle.appspot.com',
    iosClientId: '1004307429297-pu07u9ad71k5gvmnqedloqsd8is6cror.apps.googleusercontent.com',
    iosBundleId: 'com.example.lostFound',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCGECgK6hZMGsMA4gbkamMIU5K8MzAA__Y',
    appId: '1:1004307429297:ios:9a1927cc4d86d3850aaf90',
    messagingSenderId: '1004307429297',
    projectId: 'akpcircle',
    storageBucket: 'akpcircle.appspot.com',
    iosClientId: '1004307429297-ttjafsk9276sprvh0juuj2v8lvtlhoqb.apps.googleusercontent.com',
    iosBundleId: 'com.example.lostFound.RunnerTests',
  );
}
