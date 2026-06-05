import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/services/image_validation_service.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/connectivity.dart';
import '../../../doctors/domain/entities/doctor_entity.dart';
import '../../../doctors/domain/usecases/get_doctor_by_id_usecase.dart';
import '../../../doctors/presentation/bloc/doctor_bloc.dart';
import '../../../doctors/presentation/bloc/doctor_event.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// All non-UI state and logic for the profile screen, so the page is pure UI.
/// [onChange] is called whenever state changes so the host can rebuild.
class ProfileViewModel {
  ProfileViewModel({required this.onChange});
  final VoidCallback onChange;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final specialityController = TextEditingController();
  final experienceController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final availabilityController = TextEditingController();
  final servicesController = TextEditingController();
  final descriptionController = TextEditingController();

  bool editing = false;
  bool doctorLoaded = false;
  bool uploadingImage = false;
  UserEntity? cachedUser;
  DoctorEntity? doctorEntity;

  void _set(VoidCallback fn) {
    fn();
    onChange();
  }

  /// Seeds the form from the current auth state and loads the doctor record.
  void init(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated) {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    }
    final user = state is AuthAuthenticated ? state.user : null;
    cachedUser = user;
    nameController.text = user?.name ?? '';
    emailController.text = user?.email ?? '';
    if (user != null && user.isDoctor) loadDoctorProfile(user.uid);
  }

  void setEditing(bool value) => _set(() => editing = value);

  /// Re-syncs state after an [AuthAuthenticated] emission.
  void onAuthenticated(BuildContext context, UserEntity user) {
    cachedUser = user;
    nameController.text = user.name;
    emailController.text = user.email;
    if (user.isDoctor && !doctorLoaded) loadDoctorProfile(user.uid);
    // Refresh the global list of doctors so edits propagate to the home screen.
    context.read<DoctorBloc>().add(const LoadAllDoctors());
  }

  /// Pulls the doctor's stored professional details to pre-fill the form.
  Future<void> loadDoctorProfile(String uid) async {
    final result = await sl<GetDoctorByIdUseCase>()(uid);
    result.fold((_) {}, (doctor) {
      _set(() {
        doctorEntity = doctor;
        specialityController.text = doctor.speciality;
        experienceController.text = doctor.experience;
        phoneController.text = doctor.phoneNumber;
        locationController.text = doctor.location;
        availabilityController.text = doctor.availability;
        servicesController.text = doctor.services;
        descriptionController.text = doctor.description;
        doctorLoaded = true;
      });
    });
  }

  Future<void> pickAndUploadImage(BuildContext context) async {
    final user = cachedUser;
    if (user == null) return;

    final file = await ImageUploadService.pickWithChooser(context);
    if (file == null) return;

    // Doctor photos must pass the professional-criteria check before upload;
    // a failure blocks saving and shows the specific reason.
    if (user.isDoctor) {
      _set(() => uploadingImage = true);
      final result = await ImageValidationService.validateDoctorPhoto(file);
      _set(() => uploadingImage = false);
      if (!result.ok) {
        if (context.mounted) AppFeedback.showError(context, result.message);
        return;
      }
    }

    _set(() => uploadingImage = true);
    try {
      if (user.isDoctor) {
        await ImageUploadService.setDoctorPhoto(user.uid, file);
        await loadDoctorProfile(user.uid);
      } else {
        // Patient photo lives on the user record (profile-only).
        await ImageUploadService.setUserPhoto(user.uid, file);
        if (context.mounted) {
          context.read<AuthBloc>().add(const AuthCheckRequested());
        }
      }
      if (context.mounted) {
        AppFeedback.showSuccess(
            context, 'Profile picture updated successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(
            context, 'Failed to upload image: ${e.toString()}');
      }
    } finally {
      _set(() => uploadingImage = false);
    }
  }

  void saveProfile(BuildContext context, UserEntity user) {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(AuthUpdateProfileRequested(
          uid: user.uid,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          // Only doctors persist the professional fields.
          speciality: user.isDoctor ? specialityController.text.trim() : null,
          experience: user.isDoctor ? experienceController.text.trim() : null,
          phoneNumber: user.isDoctor ? phoneController.text.trim() : null,
          location: user.isDoctor ? locationController.text.trim() : null,
          availability:
              user.isDoctor ? availabilityController.text.trim() : null,
          services: user.isDoctor ? servicesController.text.trim() : null,
          description:
              user.isDoctor ? descriptionController.text.trim() : null,
        ));
    _set(() => editing = false);
  }

  void cancelEditing(UserEntity user) {
    _set(() => editing = false);
    nameController.text = user.name;
    emailController.text = user.email;
    if (user.isDoctor) loadDoctorProfile(user.uid);
  }

  void switchRole(BuildContext context, UserEntity user) {
    final newRole =
        user.role == UserRole.doctor ? UserRole.patient : UserRole.doctor;
    context.read<AuthBloc>().add(AuthSwitchRoleRequested(newRole));
  }

  Future<void> signOut(BuildContext context) async {
    final confirmed = await AppFeedback.showConfirmation(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of your account?',
      confirmLabel: 'Sign Out',
      cancelLabel: 'Cancel',
      isDanger: true,
    );
    if (!confirmed || !context.mounted) return;

    // Block sign-out while offline so the session isn't cleared without a
    // chance to re-sync.
    final online = await Connectivity.hasInternet();
    if (!context.mounted) return;
    if (!online) {
      AppFeedback.showError(
        context,
        'No internet connection. Connect to the internet to sign out.',
      );
      return;
    }
    context.read<AuthBloc>().add(const AuthSignOutRequested());
  }

  /// Delete-account action. Behaviour differs by role:
  ///  * Patient → confirms, then permanently deletes everything and signs out
  ///    (handleAuthState routes to sign-in on AuthUnauthenticated).
  ///  * Doctor → confirms, removes only the doctor profile and continues the
  ///    same account as a patient (the views switch reactively on the new
  ///    AuthAuthenticated patient state).
  Future<void> deleteAccount(BuildContext context) async {
    final user = cachedUser;
    if (user == null) return;

    if (user.isDoctor) {
      final confirmed = await AppFeedback.showConfirmation(
        context,
        title: 'Delete Doctor Profile',
        message:
            'This removes your doctor profile and professional data. Your '
            'account will continue as a patient.',
        confirmLabel: 'Continue as Patient',
        cancelLabel: 'Cancel',
        isDanger: true,
      );
      if (!confirmed || !context.mounted) return;

      context.read<AuthBloc>().add(AuthDeleteDoctorProfileRequested(
            uid: user.uid,
            name: user.name,
            email: user.email,
          ));
      // Drop the removed doctor from the global list immediately.
      context.read<DoctorBloc>().add(const LoadAllDoctors());
      return;
    }

    final confirmed = await AppFeedback.showConfirmation(
      context,
      title: 'Delete Account',
      message:
          'This permanently deletes your account and all your data (profile, '
          'appointments and notifications). This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDanger: true,
    );
    if (!confirmed || !context.mounted) return;

    context.read<AuthBloc>().add(AuthDeleteAccountRequested(user.uid));
  }

  /// Single entry point for the page's auth listener, so the page stays pure UI.
  void handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthUnauthenticated) {
      context.go(AppRoutes.signIn);
    } else if (state is AuthFailureState) {
      AppFeedback.showError(context, state.message);
    } else if (state is AuthAuthenticated) {
      onAuthenticated(context, state.user);
    }
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    specialityController.dispose();
    experienceController.dispose();
    phoneController.dispose();
    locationController.dispose();
    availabilityController.dispose();
    servicesController.dispose();
    descriptionController.dispose();
  }
}
