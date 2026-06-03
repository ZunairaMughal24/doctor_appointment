import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for app-level flags.
class AppPreferences {
  static const _kOnboardingSeen = 'onboarding_seen';

  final SharedPreferences _prefs;
  const AppPreferences(this._prefs);

  /// Whether the user has completed the onboarding carousel at least once.
  bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;

  Future<void> markOnboardingSeen() =>
      _prefs.setBool(_kOnboardingSeen, true);

  /// Clears the onboarding flag so the carousel shows again on next launch.
  /// Used by the debug-only reset shortcut.
  Future<void> resetOnboarding() => _prefs.remove(_kOnboardingSeen);
}
