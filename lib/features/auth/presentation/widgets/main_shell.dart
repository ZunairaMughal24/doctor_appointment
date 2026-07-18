import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/constants/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      // Only rebuild when the authenticated user's role changes — not on every
      // transient AuthLoading emission, which would flash the nav bar.
      buildWhen: (prev, next) {
        if (next is AuthLoading) return false;
        final prevDoctor = prev is AuthAuthenticated && prev.user.isDoctor;
        final nextDoctor = next is AuthAuthenticated && next.user.isDoctor;
        return prevDoctor != nextDoctor;
      },
      builder: (context, state) {
        final isDoctor =
            state is AuthAuthenticated && state.user.role == UserRole.doctor;
        return _ShellScaffold(isDoctor: isDoctor, child: child);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ShellScaffold extends StatelessWidget {
  final Widget child;
  final bool isDoctor;
  const _ShellScaffold({required this.child, required this.isDoctor});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/appointments')) return 1;
    if (location.startsWith('/doctors')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    HapticFeedback.lightImpact();
    switch (i) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.appointments);
      case 2:
        context.go(AppRoutes.allDoctors);
      case 3:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final apptLabel = isDoctor ? 'Schedule' : 'My Visits';

    return Scaffold(
      body: child,
      bottomNavigationBar: _PremiumNavBar(
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
        apptLabel: apptLabel,
      ),
    );
  }
}

// ── Premium 4-tab bottom nav bar ──────────────────────────────────────────────

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String apptLabel;

  const _PremiumNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.apptLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.13),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // ClipRRect clips the white container to the rounded corners
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        // Padding absorbs the system bottom inset (home indicator / gesture bar)
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          child: SizedBox(
            height: 65,
            child: Row(
              children: [
                _NavTab(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.cottage_outlined,
                  activeIcon: Icons.cottage_rounded,
                  label: 'Home',
                  onTap: onTap,
                ),
                _NavTab(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month_rounded,
                  label: apptLabel,
                  onTap: onTap,
                ),
                _NavTab(
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.medical_services_outlined,
                  activeIcon: Icons.medical_services_rounded,
                  label: 'Doctors',
                  onTap: onTap,
                ),
                _NavTab(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.manage_accounts_outlined,
                  activeIcon: Icons.manage_accounts_rounded,
                  label: 'Profile',
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Individual tab ─────────────────────────────────────────────────────────────

class _NavTab extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavTab({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill indicator wrapping the icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 18 : 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.11)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.78, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOut),
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey('${index}_$isSelected'),
                  size: 22,
                  color:
                      isSelected ? AppColors.primary : AppColors.navUnselected,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Label — always visible
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.navUnselected,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
