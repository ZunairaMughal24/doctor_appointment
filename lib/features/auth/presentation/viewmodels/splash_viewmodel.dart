import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Resolves where to send the user after the splash (auth gate), keeping the
/// page pure UI. Onboarding is always shown to unauthenticated users — there is
/// no persisted "seen" flag.
class SplashViewModel {
  const SplashViewModel();

  /// Triggers the auth check, then (after a minimum splash time) resolves to
  /// the route the page should navigate to once auth settles. The ViewModel
  /// never touches the router itself.
  Future<String> resolveDestination(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    bloc.add(const AuthCheckRequested());

    // Stay on the splash for at least 3 seconds.
    await Future.delayed(const Duration(seconds: 3));

    // If auth hasn't resolved yet, wait for it.
    if (destinationFor(bloc.state) == null) {
      await bloc.stream.firstWhere((s) => destinationFor(s) != null);
    }

    return destinationFor(bloc.state)!;
  }

  String? destinationFor(AuthState state) {
    if (state is AuthAuthenticated) {
      return state.user.isDoctor ? AppRoutes.appointments : AppRoutes.home;
    }
    if (state is AuthUnauthenticated) {
      // Always onboard unauthenticated users (no SharedPreferences flag).
      return AppRoutes.onboarding;
    }
    return null; // still loading
  }
}
