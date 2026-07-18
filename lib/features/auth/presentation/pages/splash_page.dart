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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.30),
              PulseWidget(
                minScale: 0.95,
                maxScale: 1.05,
                duration: const Duration(milliseconds: 1600),
                child: Image.asset(
                  AppAssets.appLogo,
                  height: screenHeight * 0.1,
                  width: screenWidth * 0.2,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Medic',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.primary,
                  fontSize: 25,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
