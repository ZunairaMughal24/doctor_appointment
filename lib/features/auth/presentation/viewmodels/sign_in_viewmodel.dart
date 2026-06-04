import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SignInViewModel {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? Function(String?) get emailValidator => Validators.email;
  String? Function(String?) get passwordValidator => Validators.password;

  bool validate() => formKey.currentState?.validate() ?? false;

  void submit(BuildContext context) {
    if (!validate()) return;
    context.read<AuthBloc>().add(
          AuthSignInRequested(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ),
        );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
