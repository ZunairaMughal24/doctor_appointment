import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_animations.dart';
import '../viewmodels/splash_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _vm = const SplashViewModel();

  @override
  void initState() {
    super.initState();
    _vm.resolveDestination(context).then((destination) {
      if (mounted) context.go(destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Same badge treatment as the home header avatar, scaled up.
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: SwingWidget(
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(AppAssets.appLogo),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Medic',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your Trusted Healthcare Companion',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
