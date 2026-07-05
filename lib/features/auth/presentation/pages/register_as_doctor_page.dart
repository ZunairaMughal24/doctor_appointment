import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/doctor_form_options.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/weekly_availability_field.dart';
import '../../../doctors/presentation/bloc/doctor_bloc.dart';
import '../../../doctors/presentation/bloc/doctor_event.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../viewmodels/register_as_doctor_viewmodel.dart';
import '../../../../core/widgets/custom_app_bar.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user.hasDoctorProfile) {
          AppFeedback.showSuccess(
              context, 'Doctor profile created successfully!');
          context.read<DoctorBloc>().add(const LoadAllDoctors());
          context.go(AppRoutes.profile);
        } else if (state is AuthFailureState) {
          AppFeedback.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cardBg,
        appBar: CustomAppBar(
          title: 'Register as Doctor',
          onBackPressed: () => context.pop(),
        ),
        body: Form(
          key: _vm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            physics: const BouncingScrollPhysics(),
            children: [
              const Text(
                'Your name and email are pre-filled. Complete the professional details below.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              _label('Full Name'),
              _textField(
                controller: _vm.nameController,
                hint: 'Full Name',
                icon: Icons.person_outlined,
                maxLength: 40,
                validator: _vm.nameValidator,
              ),

              _label('Email'),
              _textField(
                controller: _vm.emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                maxLength: 60,
                validator: _vm.emailValidator,
              ),

              _label('Speciality'),
              _dropdownField(
                controller: _vm.specialityController,
                hint: 'Select your speciality',
                icon: Icons.medical_services_outlined,
                options: DoctorFormOptions.specialities,
                validator: _vm.specialityValidator,
              ),

              _label('Experience'),
              _dropdownField(
                controller: _vm.experienceController,
                hint: 'Select years of experience',
                icon: Icons.workspace_premium_outlined,
                options: DoctorFormOptions.experienceYears,
                validator: _vm.experienceValidator,
              ),

              _label('Phone Number'),
              _textField(
                controller: _vm.phoneController,
                hint: 'e.g. +92 300 1234567',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                maxLength: 15,
                validator: _vm.phoneValidator,
              ),

              _label('Clinic / Hospital Location'),
              _dropdownField(
                controller: _vm.locationController,
                hint: 'Select location',
                icon: Icons.location_on_outlined,
                options: DoctorFormOptions.locations,
                validator: _vm.locationValidator,
              ),

              _label('Services'),
              _dropdownField(
                controller: _vm.servicesController,
                hint: 'Select a service',
                icon: Icons.list_alt_outlined,
                options: DoctorFormOptions.services,
                validator: _vm.servicesValidator,
              ),

              _label('Weekly Availability'),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: StatefulBuilder(
                  builder: (context, setLocal) => WeeklyAvailabilityField(
                    value: _vm.schedule,
                    onChanged: (s) {
                      _vm.updateSchedule(s);
                      setLocal(() {});
                    },
                  ),
                ),
              ),

              _label('About / Description'),
              _textField(
                controller: _vm.descriptionController,
                hint: 'Tell patients about your experience and approach',
                icon: Icons.info_outline,
                maxLines: 3,
                maxLength: 300,
                validator: _vm.descriptionValidator,
              ),

              const SizedBox(height: 28),

              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => AppButton(
                  label: 'Create Doctor Profile',
                  icon: Icons.check_circle_outline_rounded,
                  loading: state is AuthLoading,
                  onPressed: () => _vm.submit(context),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6, left: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: AppTextField(
          controller: controller,
          hint: hint,
          prefixIcon: icon,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
        ),
      );

  Widget _dropdownField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required List<String> options,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: AppDropdownField(
          controller: controller,
          hint: hint,
          prefixIcon: icon,
          options: options,
          validator: validator,
        ),
      );
}
