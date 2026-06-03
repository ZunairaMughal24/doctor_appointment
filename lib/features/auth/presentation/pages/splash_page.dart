import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_preferences.dart';
import '../../../../core/utils/app_animations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
    _goNext();
  }

  Future<void> _goNext() async {
    final bloc = context.read<AuthBloc>();

    // Stay on the splash for at least 3 seconds.
    await Future.delayed(const Duration(seconds: 3));

    // In the rare case auth hasn't resolved yet, wait for it.
    if (_destinationFor(bloc.state) == null) {
      await bloc.stream.firstWhere((s) => _destinationFor(s) != null);
    }

    if (mounted) context.go(_destinationFor(bloc.state)!);
  }

  String? _destinationFor(AuthState state) {
    if (state is AuthAuthenticated) {
      return state.user.isDoctor ? AppRoutes.appointments : AppRoutes.home;
    }
    if (state is AuthUnauthenticated) {
      // Release: onboarding on first launch only. Debug: always show it.
      final showOnboarding =
          kDebugMode || !sl<AppPreferences>().onboardingSeen;
      return showOnboarding ? AppRoutes.onboarding : AppRoutes.welcome;
    }
    return null; // still loading
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
              const Text(
                'Medic',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
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
