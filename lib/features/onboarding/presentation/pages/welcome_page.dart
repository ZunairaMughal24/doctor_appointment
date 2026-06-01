import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/constants/app_assets.dart';
import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/router/app_router.dart';

/// Landing screen for unauthenticated users: hero, tagline, and the two
/// auth entry points (Sign In / Create Account).
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Image.asset(
                    AppAssets.greetingLady,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Text(
                'Medic',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your trusted healthcare companion — find doctors, book visits, and stay on top of your care.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Sign In — filled
              _PrimaryButton(
                label: 'Sign In',
                onTap: () => context.go(AppRoutes.signIn),
              ),
              const SizedBox(height: 14),

              // Create Account — outlined
              _OutlinedButton(
                label: 'Create Account',
                onTap: () => context.go(AppRoutes.signUp),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlinedButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
