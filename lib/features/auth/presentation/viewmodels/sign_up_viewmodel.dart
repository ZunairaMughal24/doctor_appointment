import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SignUpViewModel {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? Function(String?) get nameValidator => (v) => Validators.required(v, 'Name');
  String? Function(String?) get emailValidator => Validators.email;
  String? Function(String?) get passwordValidator => Validators.password;
  String? Function(String?) get confirmPasswordValidator =>
      (v) => Validators.confirmPassword(v, passwordController.text);

  bool validate() => formKey.currentState?.validate() ?? false;

  void submit(BuildContext context) {
    if (!validate()) return;
    context.read<AuthBloc>().add(
          AuthSignUpPatientRequested(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ),
        );
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
