
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBWx23MXzBypPf3FtkLwOJ2a3eYMEHt3wg',
    appId: '1:409021218135:web:f9befb94b7300a91685212',
    messagingSenderId: '409021218135',
    projectId: 'my-ecommerce-app-123-5c941',
    authDomain: 'my-ecommerce-app-123-5c941.firebaseapp.com',
    storageBucket: 'my-ecommerce-app-123-5c941.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHSdFRqZYFGtDhfyRifsp04cu91YnkdmM',
    appId: '1:409021218135:android:e8728fb45ed99861685212',
    messagingSenderId: '409021218135',
    projectId: 'my-ecommerce-app-123-5c941',
    storageBucket: 'my-ecommerce-app-123-5c941.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB04yV_hf_evuSvfNEXXlJx1IhAuSRhn3g',
    appId: '1:409021218135:ios:e65df5c483678864685212',
    messagingSenderId: '409021218135',
    projectId: 'my-ecommerce-app-123-5c941',
    storageBucket: 'my-ecommerce-app-123-5c941.firebasestorage.app',
    iosBundleId: 'com.example.myApp',
  );

}