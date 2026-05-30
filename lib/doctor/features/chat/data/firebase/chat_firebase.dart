// lib/doctor/features/chat/data/firebase/chat_firebase.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:grad_project/firebase_options.dart';

class ChatFirebase {
  ChatFirebase._();

  static Future<void> ensureInitialized() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }
}
