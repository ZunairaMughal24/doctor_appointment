import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:medic/core/constants/app_assets.dart';
import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/constants/app_text_styles.dart';
import 'package:medic/core/router/app_router.dart';
import 'package:medic/core/utils/app_animations.dart';
import 'package:medic/core/widgets/app_button.dart';

/// Landing screen for unauthenticated users.
///
/// Deliberately a different composition from the onboarding slides: a gradient
/// hero with a clustered "care team" of doctor avatars on top, and a white
/// rounded CTA panel below holding the two auth entry points.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // One continuous gradient for the whole screen — dark at the top,
    // fading to the light background color by the time it reaches the
    // text/buttons. No separate panel, so no boundary between two solid
    // colors for a seam to ever show up on.
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 12, 91, 128),
              Color.fromARGB(255, 140, 199, 226),
              AppColors.background,
            ],
            stops: [0.0, 0.6, 0.72],
          ),
        ),
        child: Column(
          children: [
            // ── Hero ───────────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: SafeArea(
                bottom: false,
                child: Center(child: _AvatarCluster()),
              ),
            ),

            // ── Welcome text + CTAs ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: Text(
                        'Welcome to Medic',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 26,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Your trusted healthcare companion — find doctors, book visits, and stay on top of your care.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 14.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 450),
                      child: AppButton(
                        label: 'Sign In',
                        onPressed: () => context.go(AppRoutes.signIn),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 600),
                      child: AppButton.outlined(
                        label: 'Create Account',
                        onPressed: () => context.go(AppRoutes.signUp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A central doctor avatar surrounded by a ring of smaller ones — a "care team".
class _AvatarCluster extends StatelessWidget {
  const _AvatarCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faint concentric rings.
          _ring(260),
          _ring(190),
          // Orbiting avatars — each bobs on its own stagger.
          const Positioned(
            top: 6,
            child: FloatingWidget(
              distance: 14,
              child: _Avatar(AppAssets.doctorMale1, 30),
            ),
          ),
          const Positioned(
            right: 8,
            child: FloatingWidget(
              delay: Duration(milliseconds: 300),
              distance: 12,
              child: _Avatar(AppAssets.doctorFemale2, 26),
            ),
          ),
          const Positioned(
            bottom: 14,
            left: 22,
            child: FloatingWidget(
              delay: Duration(milliseconds: 600),
              distance: 16,
              child: _Avatar(AppAssets.doctorMale2, 24),
            ),
          ),
          const Positioned(
            bottom: 6,
            right: 28,
            child: FloatingWidget(
              delay: Duration(milliseconds: 900),
              distance: 11,
              child: _Avatar(AppAssets.doctorMale3, 22),
            ),
          ),
          const Positioned(
            left: 10,
            child: FloatingWidget(
              delay: Duration(milliseconds: 1200),
              distance: 13,
              child: _Avatar(AppAssets.doctorFemale1, 26),
            ),
          ),
          // Center brand mark — gentle pulse.
          PulseWidget(
            minScale: 0.97,
            maxScale: 1.03,
            duration: const Duration(milliseconds: 2000),
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Image.asset(AppAssets.appLogo, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
      );
}

class _Avatar extends StatelessWidget {
  final String image;
  final double radius;
  const _Avatar(this.image, this.radius);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: AssetImage(image),
      ),
    );
  }
}
