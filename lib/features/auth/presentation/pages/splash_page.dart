import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() {
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // authStateChanges().first reliably waits for Firebase to restore
      // the persisted session — currentUser can be null briefly on cold start
      final user = await FirebaseAuth.instance.authStateChanges().first;

      if (!mounted) return;

      if (user == null) {
        context.go(AppRoutes.signIn);
        return;
      }

      // Load the authenticated user into AuthBloc so every screen
      // (especially ProfilePage) can read it immediately
      context.read<AuthBloc>().add(const AuthCheckRequested());

      try {
        final doc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(user.uid)
            .get();
        if (!mounted) return;
        context.go(doc.exists ? AppRoutes.appointments : AppRoutes.home);
      } catch (_) {
        if (mounted) context.go(AppRoutes.home);
      }
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
              Image.asset(
                AppAssets.appLogo,
                height: screenHeight * 0.1,
                width: screenWidth * 0.2,
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
