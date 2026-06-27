import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_error_banner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../viewmodels/sign_up_viewmodel.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final SignUpViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SignUpViewModel();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          }
        },
        child: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primaryDark,
                AppColors.surface,
                AppColors.tabUnselected,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: ListView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  height: screenHeight * 0.37,
                  child: Image.asset(
                    AppAssets.signUpImage,
                    alignment: Alignment.topCenter,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 28),
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 28, right: 20),
                  child: Text(
                    "Please enter your name, email and password to create account",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Form(
                  key: _vm.formKey,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _vm.nameController,
                          hint: 'Name',
                          prefixIcon: Icons.person,
                          maxLength: 40,
                          validator: _vm.nameValidator,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _vm.emailController,
                          hint: 'Email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          maxLength: 60,
                          validator: _vm.emailValidator,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _vm.passwordController,
                          hint: 'Password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          validator: _vm.passwordValidator,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _vm.confirmPasswordController,
                          hint: 'Confirm password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          validator: _vm.confirmPasswordValidator,
                        ),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (_, next) =>
                      next is AuthFailureState || next is AuthLoading,
                  builder: (context, state) {
                    if (state is! AuthFailureState) {
                      return SizedBox(height: screenHeight * 0.035);
                    }
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.06, 16, screenWidth * 0.06, 16),
                      child: AuthErrorBanner(message: state.message),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Sign Up',
                        loading: state is AuthLoading,
                        onPressed: () => _vm.submit(context),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.signIn),
                  child: const Text("Already have an account?",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
