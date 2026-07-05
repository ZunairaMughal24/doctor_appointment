import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/doctor_form_options.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_bloc.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_event.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';
import '../viewmodels/doctor_sign_up_viewmodel.dart';
import 'package:fyp/core/widgets/custom_app_bar.dart';

class DoctorSignUpPage extends StatefulWidget {
  const DoctorSignUpPage({super.key});

  @override
  State<DoctorSignUpPage> createState() => _DoctorSignUpPageState();
}

class _DoctorSignUpPageState extends State<DoctorSignUpPage> {
  late final DoctorSignUpViewModel _vm;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _vm = DoctorSignUpViewModel();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: CustomAppBar(
        title: "Sign Up as Doctor",
        onBackPressed: () => context.pop(),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthAuthenticated) {
            // Account created — upload the required photo onto the new record,
            // then refresh the global doctor list and continue.
            setState(() => _finishing = true);
            try {
              await _vm.uploadPhotoFor(state.user.uid);
            } catch (e) {
              debugPrint('Photo upload failed after doctor sign-up: $e');
            }
            if (!context.mounted) return;
            context.read<DoctorBloc>().add(const LoadAllDoctors());
            context.go(AppRoutes.appointments);
          }
        },
        child: Container(
          color: AppColors.cardBg,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _vm.formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _vm.pickPhoto(context);
                            if (mounted) setState(() {});
                          },
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: _vm.photo != null
                                ? FileImage(_vm.photo!)
                                : null,
                            child: _vm.photo == null
                                ? const Icon(Icons.add_a_photo,
                                    color: AppColors.primary, size: 28)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please upload a photo with a plain white background, '
                          'face centered and looking straight at the camera.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _vm.photo == null
                              ? 'Tap to add a photo (required)'
                              : 'Tap to change photo',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.primary),
                        ),
                        if (_vm.attemptedWithoutPhoto && _vm.photo == null) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Profile photo is required.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLabel("Name"),
                  _buildInputField(
                    _vm.nameController,
                    "Enter your name",
                    maxLength: 40,
                    validator: _vm.nameValidator,
                  ),
                  _buildLabel("Email"),
                  _buildInputField(
                    _vm.emailController,
                    "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 60,
                    validator: _vm.emailValidator,
                  ),
                  _buildLabel("Password"),
                  _buildInputField(
                    _vm.passwordController,
                    "Enter your password",
                    obscure: true,
                    validator: _vm.passwordValidator,
                  ),
                  _buildLabel("Confirm password"),
                  _buildInputField(
                    _vm.confirmPasswordController,
                    "re-type the password",
                    obscure: true,
                    validator: _vm.confirmPasswordValidator,
                  ),
                  _buildLabel("Speciality"),
                  _buildDropdownField(
                    _vm.specialityController,
                    "Select your speciality",
                    options: DoctorFormOptions.specialities,
                    validator: _vm.specialityValidator,
                  ),
                  _buildLabel("Experience"),
                  _buildDropdownField(
                    _vm.experienceController,
                    "Select years of experience",
                    options: DoctorFormOptions.experienceYears,
                    validator: _vm.experienceValidator,
                  ),
                  _buildLabel("Contact number"),
                  _buildInputField(
                    _vm.numberController,
                    "Enter number",
                    keyboardType: TextInputType.phone,
                    maxLength: 15,
                    validator: _vm.phoneValidator,
                  ),
                  _buildLabel("Location"),
                  _buildDropdownField(
                    _vm.locationController,
                    "Select clinic / hospital",
                    options: DoctorFormOptions.locations,
                    validator: _vm.locationValidator,
                  ),
                  _buildLabel("Availability"),
                  _buildDropdownField(
                    _vm.availabilityController,
                    "Select days & hours",
                    options: DoctorFormOptions.availability,
                    validator: _vm.availabilityValidator,
                  ),
                  _buildLabel("Your Services"),
                  _buildDropdownField(
                    _vm.servicesController,
                    "Select a service",
                    options: DoctorFormOptions.services,
                    validator: _vm.servicesValidator,
                  ),
                  _buildLabel("About / Description"),
                  _buildInputField(
                    _vm.descriptionController,
                    "Tell patients about your experience and approach",
                    maxLines: 3,
                    maxLength: 300,
                    validator: _vm.descriptionValidator,
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          label: 'Sign Up',
                          loading: state is AuthLoading || _finishing,
                          onPressed: () {
                            _vm.submit(context);
                            setState(() {}); // reflect inline photo error
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
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: AppTextField(
        controller: controller,
        hint: hint,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField(
    TextEditingController controller,
    String hint, {
    required List<String> options,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: AppDropdownField(
        controller: controller,
        hint: hint,
        options: options,
        validator: validator,
      ),
    );
  }
}
