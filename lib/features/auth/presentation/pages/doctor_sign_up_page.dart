import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
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
                  _buildInputField(_nameController, "Enter your name",
                      validator: (v) => Validators.required(v, 'Name')),
                  _buildLabel("Email"),
                  _buildInputField(_emailController, "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email),
                  _buildLabel("Password"),
                  _buildInputField(_passwordController, "Enter your password",
                      obscure: true, validator: Validators.password),
                  _buildLabel("Confirm password"),
                  _buildInputField(
                      _confirmPasswordController, "re-type the password",
                      obscure: true,
                      validator: (v) => Validators.confirmPassword(
                          v, _passwordController.text)),
                  _buildLabel("Speciality"),
                  _buildInputField(
                      _specialityController, "Mention your speciality",
                      validator: (v) => Validators.required(v, 'Speciality')),
                  _buildLabel("Experience"),
                  _buildInputField(
                      _experienceController, "Your work experience",
                      validator: (v) => Validators.required(v, 'Experience')),
                  _buildLabel("Contact number"),
                  _buildInputField(_numberController, "Enter number",
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone),
                  _buildLabel("Location"),
                  _buildInputField(_locationController, "Enter location",
                      validator: (v) => Validators.required(v, 'Location')),
                  _buildLabel("Availability"),
                  _buildInputField(_availabilityController, "Days & hours",
                      validator: (v) => Validators.required(v, 'Availability')),
                  _buildLabel("Your Services"),
                  _buildInputField(_servicesController, "Enter Your Services",
                      validator: (v) => Validators.required(v, 'Services')),
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

  Widget _buildInputField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: AppTextField(
        controller: controller,
        hint: hint,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator ?? (v) => Validators.required(v, 'This field'),
      ),
    );
  }
}


