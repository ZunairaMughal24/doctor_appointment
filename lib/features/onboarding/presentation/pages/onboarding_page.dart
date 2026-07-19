import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:medic/core/constants/app_assets.dart';
import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/constants/app_text_styles.dart';
import 'package:medic/core/router/app_router.dart';
import 'package:medic/core/widgets/app_button.dart';
import 'package:medic/features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'package:medic/features/onboarding/presentation/widgets/doctor_hero_illustration.dart';
import 'package:medic/features/onboarding/presentation/widgets/onboarding_arts.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingViewModel _vm;

  static const _slides = [
    _Slide(
      illustration: DoctorHeroIllustration(
        mainImage: AppAssets.doctorMale1,
        floatingImages: [
          AppAssets.doctorFemale1,
          AppAssets.doctorMale2,
          AppAssets.doctorFemale2,
        ],
      ),
      accent: Color(0xFFD4E5F3),
      title: 'Find the right doctor, fast',
      subtitle:
          'Browse trusted specialists by category and discover the right care in seconds.',
    ),
    _Slide(
      illustration: ManageCareArt(),
      accent: Color(0xFFD7F0DD),
      title: 'Book & manage with ease',
      subtitle:
          'Pick a time that suits you, confirm in a tap, and switch seamlessly '
          'between patient and doctor modes.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _vm = OnboardingViewModel(slideCount: _slides.length);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip — hidden on the last slide.
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: _vm.isLast ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed:
                      _vm.isLast ? null : () => context.go(AppRoutes.welcome),
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _vm.pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _vm.onPageChanged(i)),
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => _Dot(active: i == _vm.index),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppButton(
                label: _vm.isLast ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_vm.isLast) {
                    context.go(AppRoutes.welcome);
                  } else {
                    _vm.next();
                  }
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final Widget illustration;
  final Color accent;
  final String title;
  final String subtitle;
  const _Slide({
    required this.illustration,
    required this.accent,
    required this.title,
    required this.subtitle,
  });
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Per-slide accent backdrop.
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: slide.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  slide.illustration,
                ],
              ),
            ),
          ),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
