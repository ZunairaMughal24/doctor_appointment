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
import '../viewmodels/sign_in_viewmodel.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final SignInViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SignInViewModel();
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
            context.go(
              state.user.isDoctor ? AppRoutes.appointments : AppRoutes.home,
            );
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
            padding: EdgeInsets.only(top: screenHeight * 0.05),
            child: ListView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: screenHeight * 0.35,
                  width: screenWidth * 0.7,
                  child: Image.asset(
                    AppAssets.signInImage,
                    alignment: Alignment.topCenter,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 28),
                  child: Text(
                    "Login",
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
                    "Please enter your email and password access your account",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 133, 143, 148),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Form(
                  key: _vm.formKey,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _vm.emailController,
                          hint: 'Email',
                          prefixIcon: Icons.person,
                          keyboardType: TextInputType.emailAddress,
                          maxLength: 60,
                          validator: _vm.emailValidator,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _vm.passwordController,
                          hint: 'Password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          validator: _vm.passwordValidator,
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
                      return const SizedBox(height: 50);
                    }
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.06, 24, screenWidth * 0.06, 18),
                      child: AuthErrorBanner(message: state.message),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Sign In',
                        loading: state is AuthLoading,
                        onPressed: () => _vm.submit(context),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.signUp),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text("Don't have an account?",
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


