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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can re-run the FlutterFire CLI to generate but this app is for Mobile.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can re-run the FlutterFire CLI to generate but this app is for Mobile.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can re-run the FlutterFire CLI to generate but this app is for Mobile.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can re-run the FlutterFire CLI to generate but this app is for Mobile.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDk2Pxtd_0plwA8eGyXXlABJywQFk3SokQ',
    appId: '1:778466348549:android:92ad6cad1c5bde2c81566c',
    messagingSenderId: '778466348549',
    projectId: 'ai-fitness-coach-project',
    storageBucket: 'ai-fitness-coach-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQjwvix8MWPDv7Fk_P3Vt6iIES4Dh2BNE',
    appId: '1:778466348549:ios:fdfd83beee218c6281566c',
    messagingSenderId: '778466348549',
    projectId: 'ai-fitness-coach-project',
    storageBucket: 'ai-fitness-coach-project.firebasestorage.app',
    iosBundleId: 'com.example.aiFitnessCoach',
  );
}
