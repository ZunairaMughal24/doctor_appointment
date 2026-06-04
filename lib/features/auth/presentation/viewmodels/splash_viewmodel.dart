import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Resolves where to send the user after the splash (auth + onboarding gate),
/// keeping the page pure UI.
class SplashViewModel {
  const SplashViewModel();

  /// Triggers the auth check, then (after a minimum splash time) routes once
  /// auth resolves.
  Future<void> start(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    bloc.add(const AuthCheckRequested());

    // Stay on the splash for at least 3 seconds.
    await Future.delayed(const Duration(seconds: 3));

    // If auth hasn't resolved yet, wait for it.
    if (destinationFor(bloc.state) == null) {
      await bloc.stream.firstWhere((s) => destinationFor(s) != null);
    }

    if (context.mounted) context.go(destinationFor(bloc.state)!);
  }

  String? destinationFor(AuthState state) {
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
}
