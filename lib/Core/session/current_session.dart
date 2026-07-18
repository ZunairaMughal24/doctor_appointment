import 'package:flutter/foundation.dart';

/// Read-only view of "who is currently signed in," reactive via [Listenable].
///
/// Exists so features other than `auth` never need to import `AuthBloc`/
/// `AuthState`/`UserEntity` just to answer "what's my uid" or "am I a
/// doctor" — they depend on this contract instead, which `core/` can own
/// without depending on any specific feature.
abstract class CurrentSession extends ChangeNotifier {
  bool get isSignedIn;
  String get uid;
  String get name;
  bool get isDoctor;
}
