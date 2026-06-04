import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../viewmodels/profile_viewmodel.dart';

/// User profile screen with inline edit mode (toggled from the app-bar pencil).
///
/// Patients can edit name + email. Doctors additionally get their full
/// professional profile (speciality, experience, phone, location, availability,
/// services, description) — these are pre-filled by fetching the doctor's record
/// via [GetDoctorByIdUseCase] on open, and saved through
/// [AuthUpdateProfileRequested], which writes name/email to the users doc and
/// merges the professional fields into the matching doctors document.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ProfileViewModel(onChange: () {
      if (mounted) setState(() {});
    });
    _vm.init(context);
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
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.signIn);
        } else if (state is AuthFailureState) {
          AppFeedback.showError(context, state.message);
        } else if (state is AuthAuthenticated) {
          _vm.onAuthenticated(context, state.user);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            _vm.cachedUser = state.user;
          }
          if (_vm.cachedUser == null) {
            return const Scaffold(
              backgroundColor: AppColors.cardBg,
              body: AppLoader(),
            );
          }
          final user = _vm.cachedUser!;
          return Scaffold(
            backgroundColor: AppColors.cardBg,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: const Text(
                'Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                if (!_vm.editing)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => setState(() => _vm.editing = true),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => _vm.cancelEditing(user),
                  ),
              ],
            ),
            body: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    // ── Avatar ──────────────────────────────────────
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.primary,
                            backgroundImage: (_vm.doctorEntity?.imageUrl != null &&
                                    _vm.doctorEntity!.imageUrl!.isNotEmpty)
                                ? NetworkImage(_vm.doctorEntity!.imageUrl!)
                                : null,
                            child: _vm.uploadingImage
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : (_vm.doctorEntity?.imageUrl == null ||
                                        _vm.doctorEntity!.imageUrl!.isEmpty)
                                    ? Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )
                                    : null,
                          ),
                          if (_vm.editing && user.isDoctor)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _vm.pickAndUploadImage(context),
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isDoctor
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isDoctor ? 'Doctor Mode' : 'Patient Mode',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: user.isDoctor
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Personal / Professional Info ─────────────────
                    _sectionHeader('Personal Information'),
                    const SizedBox(height: 12),
                    Form(
                      key: _vm.formKey,
                      child: Column(
                        children: [
                          _LabeledField(
                            label: 'Full Name',
                            controller: _vm.nameController,
                            icon: Icons.person_outline,
                            enabled: _vm.editing,
                            validator: (v) =>
                                Validators.required(v, 'Name'),
                          ),
                          _LabeledField(
                            label: 'Email',
                            controller: _vm.emailController,
                            icon: Icons.email_outlined,
                            enabled: _vm.editing,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          if (user.isDoctor) ...[
                            const SizedBox(height: 16),
                            _sectionHeader('Professional Details'),
                            const SizedBox(height: 12),
                            _LabeledField(
                              label: 'Speciality',
                              controller: _vm.specialityController,
                              icon: Icons.medical_services_outlined,
                              enabled: _vm.editing,
                              validator: (v) =>
                                  Validators.required(v, 'Speciality'),
                            ),
                            _LabeledField(
                              label: 'Experience',
                              controller: _vm.experienceController,
                              icon: Icons.workspace_premium_outlined,
                              enabled: _vm.editing,
                              validator: (v) =>
                                  Validators.required(v, 'Experience'),
                            ),
                            _LabeledField(
                              label: 'Phone Number',
                              controller: _vm.phoneController,
                              icon: Icons.phone_outlined,
                              enabled: _vm.editing,
                              keyboardType: TextInputType.phone,
                              validator: Validators.phone,
                            ),
                            _LabeledField(
                              label: 'Clinic / Hospital Location',
                              controller: _vm.locationController,
                              icon: Icons.location_on_outlined,
                              enabled: _vm.editing,
                              validator: (v) =>
                                  Validators.required(v, 'Location'),
                            ),
                            _LabeledField(
                              label: 'Availability',
                              controller: _vm.availabilityController,
                              icon: Icons.access_time_outlined,
                              enabled: _vm.editing,
                              validator: (v) =>
                                  Validators.required(v, 'Availability'),
                            ),
                            _LabeledField(
                              label: 'Services',
                              controller: _vm.servicesController,
                              icon: Icons.list_alt_outlined,
                              enabled: _vm.editing,
                              maxLines: 2,
                              validator: (v) =>
                                  Validators.required(v, 'Services'),
                            ),
                            _LabeledField(
                              label: 'About / Description',
                              controller: _vm.descriptionController,
                              icon: Icons.info_outline,
                              enabled: _vm.editing,
                              maxLines: 4,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_vm.editing) ...[
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Save Changes',
                        icon: Icons.check_rounded,
                        loading: state is AuthLoading,
                        onPressed: () => _vm.saveProfile(context, user),
                      ),
                    ],

                    const SizedBox(height: 28),

                      // ── Role Switching ───────────────────────────────
                      if (user.hasDoctorProfile) ...[
                        _sectionHeader('Account Mode'),
                        const SizedBox(height: 10),
                        _card(
                          child: Row(
                            children: [
                              Icon(
                                user.isDoctor
                                    ? Icons.medical_services_outlined
                                    : Icons.person_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.isDoctor
                                          ? 'Switch to Patient Mode'
                                          : 'Switch to Doctor Mode',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      user.isDoctor
                                          ? 'Browse doctors & book appointments'
                                          : 'Manage your patient appointments',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: user.isDoctor,
                                activeThumbColor: AppColors.primary,
                                onChanged: (_) => _vm.switchRole(context, user),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ── Become a Doctor ──────────────────────────────
                      if (!user.hasDoctorProfile) ...[
                        _sectionHeader('Professional Account'),
                        const SizedBox(height: 10),
                        _card(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Icon(
                                Icons.medical_services_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            title: const Text(
                              'Register as Doctor',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            subtitle: const Text(
                              'Add a professional profile to manage patient appointments',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            onTap: () => context.push(
                              AppRoutes.registerAsDoctor,
                              extra: {
                                'name': user.name,
                                'email': user.email,
                                'uid': user.uid
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ── Sign Out ─────────────────────────────────────
                      _card(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.dangerLight,
                            child: Icon(Icons.logout, color: AppColors.error),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.error,
                            ),
                          ),
                          onTap: () => _vm.signOut(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                  if (state is AuthLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        child: const Center(
                          child: AppLoader(),
                        ),
                      ),
                    ),
                ],
              ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      );

  Widget _card({required Widget child}) => AppContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 14,
        child: child,
      );
}

/// A labelled [AppTextField] used in the profile form so view vs. edit mode
/// share the same widget (just toggling [enabled]).
class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.enabled,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          AppTextField(
            controller: controller,
            hint: label,
            prefixIcon: icon,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
          ),
        ],
      ),
    );
  }
}
