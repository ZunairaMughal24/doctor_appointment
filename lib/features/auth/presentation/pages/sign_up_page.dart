import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            AppFeedback.showError(context, state.message);
          } else if (state is AuthAuthenticated) {
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
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          hint: 'Name',
                          icon: Icons.person,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          validator: (v) => Validators.required(v, 'Name'),
                        ),
                        _buildInputField(
                          controller: _emailController,
                          hint: 'Email',
                          icon: Icons.email,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          validator: Validators.email,
                        ),
                        _buildInputField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          obscure: true,
                          validator: Validators.password,
                        ),
                        _buildInputField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm password',
                          icon: Icons.lock,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          obscure: true,
                          validator: (v) => Validators.confirmPassword(
                              v, _passwordController.text),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.035),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Container(
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.88,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.primary,
                                width: 1.0),
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.primary,
                            boxShadow: const [
                              BoxShadow(
                                  color: AppColors.shadowCard,
                                  offset: Offset(02, 03),
                                  blurRadius: 0.5,
                                  spreadRadius: 0.1),
                            ]),
                        child: state is AuthLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white))
                            : TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context
                                        .read<AuthBloc>()
                                        .add(AuthSignUpPatientRequested(
                                          name: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        ));
                                  }
                                },
                                child: const Text("Sign up",
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            AppColors.surface),
                                    textAlign: TextAlign.center),
                              ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.doctorSignUp),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double screenHeight,
    required double screenWidth,
    required String? Function(String?)? validator,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Container(
        height: screenHeight * 0.06,
        width: screenWidth * 0.88,
        decoration: BoxDecoration(
            border: Border.all(
                color: AppColors.inputBorder, width: 1.0),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadowLight,
                  offset: Offset(02, 03),
                  blurRadius: 0.5,
                  spreadRadius: 0.1),
            ]),
        child: TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 17.0,
              color: AppColors.primary,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}


