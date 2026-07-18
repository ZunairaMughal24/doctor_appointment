import 'package:flutter/material.dart';

/// Drives the onboarding slides (page control + completion), keeping the page
/// pure UI. The page wraps mutations in setState for the dots/labels, and
/// navigates itself once [isLast] is true — this ViewModel never touches
/// the router.
class OnboardingViewModel {
  OnboardingViewModel({required this.slideCount});

  final int slideCount;
  final pageController = PageController();
  int index = 0;

  bool get isLast => index == slideCount - 1;

  void onPageChanged(int i) => index = i;

  /// Advances to the next slide. No-op on the last slide — the page decides
  /// to navigate on instead.
  void next() {
    if (!isLast) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  void dispose() => pageController.dispose();
}
