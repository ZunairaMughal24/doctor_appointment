import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase project credentials for Auth/Firestore.
///
/// Values are read at runtime from the gitignored `.env` file (see `.env.example`).
class FirebaseConfig {
  FirebaseConfig._();

  static String get appId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  static String get apiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get messagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  static String get projectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  /// True once real credentials are present, so we can fail fast with a
  /// clear message if `.env` is missing/empty.
  static bool get isConfigured =>
      appId.isNotEmpty &&
      apiKey.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;
}
