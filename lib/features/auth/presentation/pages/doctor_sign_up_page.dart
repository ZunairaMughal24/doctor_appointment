import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_event.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';

class DoctorSignUpPage extends StatefulWidget {
  const DoctorSignUpPage({super.key});

  @override
  State<DoctorSignUpPage> createState() => _DoctorSignUpPageState();
}

class _DoctorSignUpPageState extends State<DoctorSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specialityController = TextEditingController();
  final _experienceController = TextEditingController();
  final _numberController = TextEditingController();
  final _locationController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _servicesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specialityController.dispose();
    _experienceController.dispose();
    _numberController.dispose();
    _locationController.dispose();
    _availabilityController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          "Sign Up as Doctor",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthAuthenticated) {
            context.go(AppRoutes.appointments);
          }
        },
        child: Container(
          color: AppColors.cardBg,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildLabel("Name"),
                  _buildInputField(_nameController, "Enter your name"),
                  _buildLabel("Email"),
                  _buildInputField(_emailController, "Enter your email"),
                  _buildLabel("Password"),
                  _buildInputField(_passwordController, "Enter your password",
                      obscure: true),
                  _buildLabel("Confirm password"),
                  _buildInputField(
                      _confirmPasswordController, "re-type the password",
                      obscure: true),
                  _buildLabel("Speciality"),
                  _buildInputField(
                      _specialityController, "Mention your speciality"),
                  _buildLabel("Experience"),
                  _buildInputField(
                      _experienceController, "Your work experience"),
                  _buildLabel("Contact number"),
                  _buildInputField(_numberController, "Enter number"),
                  _buildLabel("Location"),
                  _buildInputField(_locationController, "Enter location"),
                  _buildLabel("Availability"),
                  _buildInputField(_availabilityController, "Days & hours"),
                  _buildLabel("Your Services"),
                  _buildInputField(_servicesController, "Enter Your Services"),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          label: 'Sign Up',
                          loading: state is AuthLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_passwordController.text !=
                                  _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Passwords do not match")),
                                );
                                return;
                              }
                              context
                                  .read<AuthBloc>()
                                  .add(AuthSignUpDoctorRequested(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    speciality:
                                        _specialityController.text.trim(),
                                    experience:
                                        _experienceController.text.trim(),
                                    phoneNumber: _numberController.text.trim(),
                                    location: _locationController.text.trim(),
                                    availability:
                                        _availabilityController.text.trim(),
                                    services: _servicesController.text.trim(),
                                  ));
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: AppTextField(
        controller: controller,
        hint: hint,
        obscureText: obscure,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "This field is required";
          }
          return null;
        },
      ),
    );
  }
}


