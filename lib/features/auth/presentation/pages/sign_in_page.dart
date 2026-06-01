import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthAuthenticated) {
            context.go(
              state.user.isDoctor ? AppRoutes.appointments : AppRoutes.home,
            );
          }
        },
        child: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 146, 249, 254),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primaryDark,
                Color.fromARGB(255, 254, 255, 255),
                Color.fromARGB(255, 116, 168, 190),
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
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                        child: Container(
                          height: screenHeight * 0.06,
                          width: screenWidth * 0.88,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      AppColors.inputBorder,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(16),
                              color: const Color.fromARGB(255, 255, 255, 255),
                              boxShadow: const [
                                BoxShadow(
                                    color: AppColors.shadowLight,
                                    offset: Offset(02, 03),
                                    blurRadius: 0.5,
                                    spreadRadius: 0.1),
                              ]),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textAlign: TextAlign.justify,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your email";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                fontSize: 17.0,
                                color: AppColors.primary,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.015),
                        child: Container(
                          height: screenHeight * 0.06,
                          width: screenWidth * 0.88,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 207, 206, 206),
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(16),
                              color: const Color.fromARGB(255, 167, 206, 224),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromARGB(255, 207, 206, 206),
                                    offset: Offset(02, 03),
                                    blurRadius: 0.5,
                                    spreadRadius: 0.1),
                              ]),
                          child: TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your password";
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                fontSize: 17.0,
                                color: AppColors.primary,
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
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
                                        .add(AuthSignInRequested(
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        ));
                                  }
                                },
                                child: const Text("Sign In",
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 254, 255, 255)),
                                    textAlign: TextAlign.center),
                              ),
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


