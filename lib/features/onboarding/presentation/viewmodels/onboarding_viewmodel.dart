import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/router/app_router.dart';

/// Drives the onboarding slides (page control + completion), keeping the page
/// pure UI. The page wraps mutations in setState for the dots/labels.
class OnboardingViewModel {
  OnboardingViewModel({required this.slideCount});

  final int slideCount;
  final pageController = PageController();
  int index = 0;

  bool get isLast => index == slideCount - 1;

  void onPageChanged(int i) => index = i;

  /// Moves on to the welcome screen. Onboarding has no persisted "seen" flag —
  /// it always shows to unauthenticated users.
  void finish(BuildContext context) => context.go(AppRoutes.welcome);

  void next(BuildContext context) {
    if (isLast) {
      finish(context);
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  void dispose() => pageController.dispose();
}
