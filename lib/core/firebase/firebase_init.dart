import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    const options = FirebaseOptions(
      apiKey: 'AIzaSyBFskytdtI1_tZPl7yq9xQzeVjXlaQXYuk',
      authDomain: 'hairsalon-11f3e.firebaseapp.com',
      projectId: 'hairsalon-11f3e',
      storageBucket: 'hairsalon-11f3e.appspot.com',
      messagingSenderId: '1090704917144',
      appId: '1:1090704917144:web:d20d6d500aace155d786ed',
      measurementId: 'G-R0ZG2S9FE4',
    );
    await Firebase.initializeApp(options: options);
    _initialized = true;
  }
}


