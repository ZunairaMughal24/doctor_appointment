import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/di/injection_container.dart';
import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/core/services/app_preferences.dart';

/// Navigation + actions for the welcome screen, keeping the page pure UI.
class WelcomeViewModel {
  const WelcomeViewModel();

  void goSignIn(BuildContext context) => context.go(AppRoutes.signIn);
  void goSignUp(BuildContext context) => context.go(AppRoutes.signUp);

  /// Debug-only: clears the onboarding flag and replays it.
  void replayOnboarding(BuildContext context) {
    sl<AppPreferences>().resetOnboarding();
    context.go(AppRoutes.onboarding);
  }
}
