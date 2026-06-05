import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/router/app_router.dart';

/// Navigation for the welcome screen, keeping the page pure UI.
class WelcomeViewModel {
  const WelcomeViewModel();

  void goSignIn(BuildContext context) => context.go(AppRoutes.signIn);
  void goSignUp(BuildContext context) => context.go(AppRoutes.signUp);
}
