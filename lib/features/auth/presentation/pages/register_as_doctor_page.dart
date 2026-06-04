import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../doctors/presentation/bloc/doctor_bloc.dart';
import '../../../doctors/presentation/bloc/doctor_event.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../viewmodels/register_as_doctor_viewmodel.dart';

class RegisterAsDoctorPage extends StatefulWidget {
  final String uid;
  final String prefillName;
  final String prefillEmail;

  const RegisterAsDoctorPage({
    super.key,
    required this.uid,
    required this.prefillName,
    required this.prefillEmail,
  });

  @override
  State<RegisterAsDoctorPage> createState() => _RegisterAsDoctorPageState();
}

class _RegisterAsDoctorPageState extends State<RegisterAsDoctorPage> {
  late final RegisterAsDoctorViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = RegisterAsDoctorViewModel(
      uid: widget.uid,
      prefillName: widget.prefillName,
      prefillEmail: widget.prefillEmail,
    );
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user.hasDoctorProfile) {
          AppFeedback.showSuccess(context, 'Doctor profile created successfully!');
          // Refresh global doctor list
          context.read<DoctorBloc>().add(const LoadAllDoctors());
          context.go(AppRoutes.profile);
        } else if (state is AuthFailureState) {
          AppFeedback.showError(context, state.message);
        }
      },
      child: Scaffold(
        body: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
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
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: screenHeight * 0.04),
                const Text(
                  'Register as Doctor',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your name and email are pre-filled. Add your professional details below.',
                  style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 100, 120, 135)),
                ),
                SizedBox(height: screenHeight * 0.03),
                Form(
                  key: _vm.formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _vm.nameController,
                        hint: 'Full Name',
                        icon: Icons.person,
                        validator: _vm.nameValidator,
                      ),
                      _buildField(
                        controller: _vm.emailController,
                        hint: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _vm.emailValidator,
                      ),
                      _buildField(
                        controller: _vm.specialityController,
                        hint: 'Speciality (e.g. Cardiologist)',
                        icon: Icons.medical_services,
                        validator: _vm.specialityValidator,
                      ),
                      _buildField(
                        controller: _vm.experienceController,
                        hint: 'Experience (e.g. 10 years)',
                        icon: Icons.workspace_premium,
                        validator: _vm.experienceValidator,
                      ),
                      _buildField(
                        controller: _vm.phoneController,
                        hint: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: _vm.phoneValidator,
                      ),
                      _buildField(
                        controller: _vm.locationController,
                        hint: 'Clinic / Hospital Location',
                        icon: Icons.location_on,
                        validator: _vm.locationValidator,
                      ),
                      _buildField(
                        controller: _vm.availabilityController,
                        hint: 'Availability (e.g. Mon–Fri: 9am–5pm)',
                        icon: Icons.access_time,
                        validator: _vm.availabilityValidator,
                      ),
                      _buildField(
                        controller: _vm.servicesController,
                        hint: 'Services (comma separated)',
                        icon: Icons.list_alt,
                        validator: _vm.servicesValidator,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Create Doctor Profile',
                      loading: state is AuthLoading,
                      onPressed: () => _vm.submit(context),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppTextField(
        controller: controller,
        hint: hint,
        prefixIcon: icon,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
