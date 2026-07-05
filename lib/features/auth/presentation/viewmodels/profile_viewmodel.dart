import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/services/image_validation_service.dart';
import '../../../../core/utils/connectivity.dart';
import '../../../doctors/domain/entities/doctor_entity.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/domain/usecases/get_doctor_reviews_usecase.dart';
import '../../../doctors/domain/usecases/get_doctor_by_id_usecase.dart';
import '../../../doctors/presentation/bloc/doctor_bloc.dart';
import '../../../doctors/presentation/bloc/doctor_event.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/errors/exceptions.dart';

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
  final servicesController = TextEditingController();
  final descriptionController = TextEditingController();

  WeeklyAvailability _weeklySchedule = WeeklyAvailability.standard;
  WeeklyAvailability get weeklySchedule => _weeklySchedule;
  void updateSchedule(WeeklyAvailability s) => _set(() => _weeklySchedule = s);

  bool editing = false;
  bool doctorLoaded = false;
  bool uploadingImage = false;
  UserEntity? cachedUser;
  DoctorEntity? doctorEntity;

  List<AppointmentEntity> _reviews = const [];
  bool _reviewsLoading = false;
  List<AppointmentEntity> get reviews => _reviews;
  bool get reviewsLoading => _reviewsLoading;

  void _set(VoidCallback fn) {
    fn();
    onChange();
  }

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

  void onAuthenticated(BuildContext context, UserEntity user) {
    cachedUser = user;
    nameController.text = user.name;
    emailController.text = user.email;
    if (!user.isDoctor && (doctorLoaded || doctorEntity != null)) {
      doctorLoaded = false;
      doctorEntity = null;
      _weeklySchedule = WeeklyAvailability.standard;
    }
    if (user.isDoctor && !doctorLoaded) loadDoctorProfile(user.uid);
    context.read<DoctorBloc>().add(const LoadAllDoctors());
  }

  Future<void> loadDoctorProfile(String uid) async {
    final result = await sl<GetDoctorByIdUseCase>()(uid);
    result.fold((_) {}, (doctor) {
      _set(() {
        doctorEntity = doctor;
        specialityController.text = doctor.speciality;
        experienceController.text = doctor.experience;
        phoneController.text = doctor.phoneNumber;
        locationController.text = doctor.location;
        servicesController.text = doctor.services;
        descriptionController.text = doctor.description;
        _weeklySchedule = doctor.schedule;
        doctorLoaded = true;
      });
      loadReviews(uid);
    });
  }

  Future<void> loadReviews(String doctorId) async {
    _set(() => _reviewsLoading = true);
    final result = await sl<GetDoctorReviewsUseCase>()(doctorId);
    result.fold(
      (_) => _set(() => _reviewsLoading = false),
      (reviews) => _set(() {
        _reviews = reviews;
        _reviewsLoading = false;
      }),
    );
  }

  /// Picks and uploads a profile photo.
  /// Returns null if the user cancelled. Otherwise returns (ok, message) where
  /// ok=true is success and ok=false means an error — the page shows the message.
  Future<({bool ok, String message})?> pickAndUploadImage(BuildContext context) async {
    final user = cachedUser;
    if (user == null) return null;

    final file = await ImageUploadService.pickWithChooser(context);
    if (file == null) return null;

    if (user.isDoctor) {
      _set(() => uploadingImage = true);
      final result = await ImageValidationService.validateDoctorPhoto(file);
      _set(() => uploadingImage = false);
      if (!result.ok) return (ok: false, message: result.message);
    }

    _set(() => uploadingImage = true);
    try {
      if (user.isDoctor) {
        await ImageUploadService.setDoctorPhoto(user.uid, file);
        await loadDoctorProfile(user.uid);
      } else {
        await ImageUploadService.setUserPhoto(user.uid, file);
        if (context.mounted) {
          context.read<AuthBloc>().add(const AuthCheckRequested());
        }
      }
      return (ok: true, message: 'Profile picture updated successfully!');
    } on ImageUploadException catch (e) {
      debugPrint('[ProfileVM] ImageUploadException caught: ${e.message}');
      return (ok: false, message: e.message);
    } catch (e, st) {
      debugPrint('[ProfileVM] Unexpected upload error: $e');
      debugPrint('$st');
      return (ok: false, message: 'Something went wrong while uploading your photo. Please try again.');
    } finally {
      _set(() => uploadingImage = false);
    }
  }

  void saveProfile(BuildContext context, UserEntity user) {
    if (!(formKey.currentState?.validate() ?? false)) {
      onChange();
      return;
    }
    context.read<AuthBloc>().add(AuthUpdateProfileRequested(
          uid: user.uid,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          speciality: user.isDoctor ? specialityController.text.trim() : null,
          experience: user.isDoctor ? experienceController.text.trim() : null,
          phoneNumber: user.isDoctor ? phoneController.text.trim() : null,
          location: user.isDoctor ? locationController.text.trim() : null,
          availability: user.isDoctor ? _buildAvailabilityString() : null,
          services: user.isDoctor ? servicesController.text.trim() : null,
          description: user.isDoctor ? descriptionController.text.trim() : null,
          weeklySchedule: user.isDoctor ? _weeklySchedule.toMap() : null,
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

  /// Checks internet then dispatches sign-out.
  /// Returns an error message if offline, null on success.
  Future<String?> signOut(BuildContext context) async {
    final online = await Connectivity.hasInternet();
    if (!context.mounted) return null;
    if (!online) {
      return 'No internet connection. Connect to the internet to sign out.';
    }
    context.read<AuthBloc>().add(const AuthSignOutRequested());
    return null;
  }

  void dispatchDeleteDoctorProfile(BuildContext context) {
    final user = cachedUser;
    if (user == null) return;
    context.read<AuthBloc>().add(AuthDeleteDoctorProfileRequested(
          uid: user.uid,
          name: user.name,
          email: user.email,
        ));
    context.read<DoctorBloc>().add(const LoadAllDoctors());
  }

  void dispatchDeleteAccount(BuildContext context) {
    final user = cachedUser;
    if (user == null) return;
    context.read<AuthBloc>().add(AuthDeleteAccountRequested(user.uid));
  }

  String _buildAvailabilityString() {
    final open = _weeklySchedule.days.where((d) => d.isOpen).toList();
    if (open.isEmpty) return 'Not available';
    final abbrs = open.map((d) => d.day.substring(0, 3)).join(', ');
    final times =
        '${WeeklyAvailability.to12h(open.first.open!)}–${WeeklyAvailability.to12h(open.first.close!)}';
    return '$abbrs: $times';
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    specialityController.dispose();
    experienceController.dispose();
    phoneController.dispose();
    locationController.dispose();
    servicesController.dispose();
    descriptionController.dispose();
  }
}
