import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/image_validation_service.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/set_doctor_photo_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class DoctorSignUpViewModel {
  final formKey = GlobalKey<FormState>();

  /// Profile photo chosen before submitting — required for doctor sign-up.
  File? photo;

  /// Set when the user tries to submit without a photo, so the page shows an
  /// inline error under the avatar (instead of a snackbar).
  bool attemptedWithoutPhoto = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final specialityController = TextEditingController();
  final experienceController = TextEditingController();
  final numberController = TextEditingController();
  final locationController = TextEditingController();
  final availabilityController = TextEditingController();
  final servicesController = TextEditingController();
  final descriptionController = TextEditingController();

  // ── Validators ──────────────────────────────────────────────────────
  String? Function(String?) get nameValidator =>
      (v) => Validators.name(v, 'Name');
  String? Function(String?) get emailValidator => Validators.email;
  String? Function(String?) get passwordValidator => Validators.password;
  String? Function(String?) get confirmPasswordValidator =>
      (v) => Validators.confirmPassword(v, passwordController.text);
  String? Function(String?) get specialityValidator =>
      (v) => Validators.text(v, 'Speciality');
  String? Function(String?) get experienceValidator =>
      (v) => Validators.text(v, 'Experience');
  String? Function(String?) get phoneValidator => Validators.phone;
  String? Function(String?) get locationValidator =>
      (v) => Validators.text(v, 'Location');
  String? Function(String?) get availabilityValidator =>
      (v) => Validators.text(v, 'Availability');
  String? Function(String?) get servicesValidator =>
      (v) => Validators.text(v, 'Services');
  String? Function(String?) get descriptionValidator =>
      (v) => Validators.text(v, 'Description', min: 10);

  // ── Actions ─────────────────────────────────────────────────────────
  bool validate() => formKey.currentState?.validate() ?? false;

  /// Opens the camera/gallery chooser and runs the professional-photo AI
  /// check, only storing the photo if it passes. Returns null if the user
  /// cancelled the picker; otherwise (ok, message) for the page to display.
  Future<({bool ok, String message})?> pickPhoto(BuildContext context) async {
    final file = await ImagePickerService.pickWithChooser(context);
    if (file == null) return null;

    final result = await ImageValidationService.validateDoctorPhoto(file);
    if (!result.ok) return (ok: false, message: result.message);

    photo = file;
    return (ok: true, message: result.message);
  }

  void submit(BuildContext context) {
    final formValid = validate();
    // Surface the photo requirement inline (the page reads this flag).
    attemptedWithoutPhoto = photo == null;
    if (!formValid || photo == null) return;
    context.read<AuthBloc>().add(AuthSignUpDoctorRequested(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          speciality: specialityController.text.trim(),
          experience: experienceController.text.trim(),
          phoneNumber: numberController.text.trim(),
          location: locationController.text.trim(),
          availability: availabilityController.text.trim(),
          services: servicesController.text.trim(),
          description: descriptionController.text.trim(),
        ));
  }

  /// Uploads the chosen photo to the freshly-created doctor's record. Called
  /// after sign-up succeeds, when the uid is known.
  Future<void> uploadPhotoFor(String uid) async {
    final file = photo;
    if (file == null) return;
    await sl<SetDoctorPhotoUseCase>()(SetPhotoParams(uid: uid, file: file));
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    specialityController.dispose();
    experienceController.dispose();
    numberController.dispose();
    locationController.dispose();
    availabilityController.dispose();
    servicesController.dispose();
    descriptionController.dispose();
  }
}
