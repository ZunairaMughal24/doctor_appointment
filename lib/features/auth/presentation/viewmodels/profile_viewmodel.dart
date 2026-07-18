import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/image_validation_service.dart';
import '../../../../core/utils/connectivity.dart';
import '../../../../core/utils/validators.dart';
import '../../../doctors/domain/entities/doctor_entity.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/domain/usecases/get_doctor_reviews_usecase.dart';
import '../../../doctors/domain/usecases/get_doctor_by_id_usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/delete_doctor_photo_usecase.dart';
import '../../domain/usecases/delete_user_photo_usecase.dart';
import '../../domain/usecases/set_doctor_photo_usecase.dart';
import '../../domain/usecases/set_user_photo_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileViewModel {
  ProfileViewModel({
    required this.onChange,
    required AuthBloc authBloc,
  }) : _authBloc = authBloc;

  final VoidCallback onChange;
  final AuthBloc _authBloc;

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

  // ── Validators ──────────────────────────────────────────────────────
  String? Function(String?) get nameValidator =>
      (v) => Validators.required(v, 'Name');
  String? Function(String?) get emailValidator => Validators.email;
  String? Function(String?) get specialityValidator =>
      (v) => Validators.required(v, 'Speciality');
  String? Function(String?) get experienceValidator =>
      (v) => Validators.required(v, 'Experience');
  String? Function(String?) get phoneValidator => Validators.phone;
  String? Function(String?) get locationValidator =>
      (v) => Validators.required(v, 'Location');
  String? Function(String?) get servicesValidator =>
      (v) => Validators.required(v, 'Services');
  String? Function(String?) get descriptionValidator =>
      (v) => Validators.required(v, 'Description');

  bool editing = false;
  bool doctorLoaded = false;
  bool uploadingImage = false;
  UserEntity? cachedUser;
  DoctorEntity? doctorEntity;

  List<AppointmentEntity> _reviews = const [];
  bool _reviewsLoading = false;
  List<AppointmentEntity> get reviews => _reviews;
  bool get reviewsLoading => _reviewsLoading;

  bool _disposed = false;

  void _set(VoidCallback fn) {
    if (_disposed) return;
    fn();
    onChange();
  }

  void init() {
    final state = _authBloc.state;
    if (state is! AuthAuthenticated) {
      _authBloc.add(const AuthCheckRequested());
    }
    final user = state is AuthAuthenticated ? state.user : null;
    cachedUser = user;
    nameController.text = user?.name ?? '';
    emailController.text = user?.email ?? '';
    if (user != null && user.isDoctor) loadDoctorProfile(user.uid);
  }

  void setEditing(bool value) => _set(() => editing = value);

  void onAuthenticated(UserEntity user) {
    cachedUser = user;
    nameController.text = user.name;
    emailController.text = user.email;
    if (!user.isDoctor && (doctorLoaded || doctorEntity != null)) {
      doctorLoaded = false;
      doctorEntity = null;
      _weeklySchedule = WeeklyAvailability.standard;
    }
    if (user.isDoctor && !doctorLoaded) loadDoctorProfile(user.uid);
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

  /// Uploads [file] as the profile photo.
  /// Returns (ok, message) where ok=true is success and ok=false means an
  /// error — the page shows the message. Picking the file itself is the
  /// View's job (it needs BuildContext to show the camera/gallery chooser).
  Future<({bool ok, String message})> uploadImage(File file) async {
    final user = cachedUser;
    if (user == null) return (ok: false, message: 'User not signed in.');

    if (user.isDoctor) {
      _set(() => uploadingImage = true);
      final result = await ImageValidationService.validateDoctorPhoto(file);
      _set(() => uploadingImage = false);
      if (!result.ok) return (ok: false, message: result.message);
    }

    _set(() => uploadingImage = true);
    final params = SetPhotoParams(uid: user.uid, file: file);
    final either = user.isDoctor
        ? await sl<SetDoctorPhotoUseCase>()(params)
        : await sl<SetUserPhotoUseCase>()(params);
    _set(() => uploadingImage = false);

    String? errorMessage;
    either.fold((failure) => errorMessage = failure.userMessage, (_) {});
    if (errorMessage != null) return (ok: false, message: errorMessage!);

    if (user.isDoctor) {
      await loadDoctorProfile(user.uid);
    } else {
      _authBloc.add(const AuthCheckRequested());
    }
    return (ok: true, message: 'Profile picture updated successfully!');
  }

  /// Removes the current profile photo and clears it in databases.
  Future<({bool ok, String message})> removeProfilePhoto() async {
    final user = cachedUser;
    if (user == null) return (ok: false, message: 'User not signed in.');

    _set(() => uploadingImage = true);
    final either = user.isDoctor
        ? await sl<DeleteDoctorPhotoUseCase>()(user.uid)
        : await sl<DeleteUserPhotoUseCase>()(user.uid);
    _set(() => uploadingImage = false);

    String? errorMessage;
    either.fold((failure) => errorMessage = failure.userMessage, (_) {});
    if (errorMessage != null) return (ok: false, message: errorMessage!);

    if (user.isDoctor) {
      await loadDoctorProfile(user.uid);
    } else {
      _authBloc.add(const AuthCheckRequested());
    }
    return (ok: true, message: 'Profile picture removed successfully!');
  }

  void saveProfile(UserEntity user) {
    if (!(formKey.currentState?.validate() ?? false)) {
      onChange();
      return;
    }
    _authBloc.add(AuthUpdateProfileRequested(
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
      weeklySchedule: user.isDoctor ? _weeklySchedule : null,
    ));
    _set(() => editing = false);
  }

  void cancelEditing(UserEntity user) {
    _set(() => editing = false);
    nameController.text = user.name;
    emailController.text = user.email;
    if (user.isDoctor) loadDoctorProfile(user.uid);
  }

  void switchRole(UserEntity user) {
    final newRole =
        user.role == UserRole.doctor ? UserRole.patient : UserRole.doctor;
    _authBloc.add(AuthSwitchRoleRequested(newRole));
  }

  /// Checks internet then dispatches sign-out.
  /// Returns an error message if offline, null on success.
  Future<String?> signOut() async {
    final online = await Connectivity.hasInternet();
    if (!online) {
      return 'No internet connection. Connect to the internet to sign out.';
    }
    _authBloc.add(const AuthSignOutRequested());
    return null;
  }

  void dispatchDeleteDoctorProfile() {
    final user = cachedUser;
    if (user == null) return;
    // AuthBloc re-emits AuthAuthenticated once the account reverts to a
    // patient; the app-root listener reloads the doctor list from that.
    _authBloc.add(AuthDeleteDoctorProfileRequested(
      uid: user.uid,
      name: user.name,
      email: user.email,
    ));
  }

  void dispatchDeleteAccount() {
    final user = cachedUser;
    if (user == null) return;
    _authBloc.add(AuthDeleteAccountRequested(user.uid));
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
    _disposed = true;
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
