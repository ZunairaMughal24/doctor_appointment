import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase project credentials for profile-photo storage.
///
/// Values are read at runtime from the gitignored `.env` file (see `.env.example`).
/// The anon/publishable key is public-by-design — your data is protected by
/// Storage bucket policies / RLS, not by hiding this key.
class SupabaseConfig {
  SupabaseConfig._();

  /// e.g. https://abcdefghijklmno.supabase.co
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  /// The "anon public" / publishable API key.
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Storage bucket that holds profile photos. Must match the bucket name in
  /// the Supabase dashboard (Storage → New bucket), marked Public.
  static const String photoBucket = 'profile-pictures';

  /// True once real credentials are present, so the app can skip Supabase init
  /// (and fail fast with a clear message) when `.env` is missing/empty.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
