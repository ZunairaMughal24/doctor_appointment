import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class RegisterAsDoctorViewModel {
  final String uid;

  RegisterAsDoctorViewModel({
    required this.uid,
    String prefillName = '',
    String prefillEmail = '',
  })  : nameController = TextEditingController(text: prefillName),
        emailController = TextEditingController(text: prefillEmail);

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController;
  final TextEditingController emailController;
  final specialityController = TextEditingController();
  final experienceController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final servicesController = TextEditingController();
  final descriptionController = TextEditingController();

  // Weekly schedule — replaces the availability string dropdown.
  WeeklyAvailability _schedule = WeeklyAvailability.standard;
  WeeklyAvailability get schedule => _schedule;
  void updateSchedule(WeeklyAvailability s) => _schedule = s;

  // ── Validators ──────────────────────────────────────────────────────
  String? Function(String?) get nameValidator =>
      (v) => Validators.required(v, 'Full name');
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

  // ── Actions ─────────────────────────────────────────────────────────
  bool validate() => formKey.currentState?.validate() ?? false;

  void submit(BuildContext context) {
    if (!validate()) return;
    context.read<AuthBloc>().add(AuthRegisterAsDoctorRequested(
          uid: uid,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          speciality: specialityController.text.trim(),
          experience: experienceController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          location: locationController.text.trim(),
          availability: _buildAvailabilityString(),
          services: servicesController.text.trim(),
          description: descriptionController.text.trim(),
          weeklySchedule: _schedule,
        ));
  }

  String _buildAvailabilityString() {
    final open = _schedule.days.where((d) => d.isOpen).toList();
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
