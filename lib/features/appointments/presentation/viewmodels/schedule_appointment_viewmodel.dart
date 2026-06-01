import 'package:flutter/material.dart';
import 'package:fyp/core/utils/validators.dart';
import 'package:fyp/features/appointments/domain/entities/appointment_entity.dart';

/// Holds all non-UI logic for the schedule appointment form.
/// The page owns an instance of this and calls its methods;
/// it never touches formatting, day resolution, or entity construction directly.
class ScheduleAppointmentViewModel {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  final dayController = TextEditingController();

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  /// Called by the page after the date picker resolves.
  /// Writes the formatted date and the resolved weekday name into the controllers.
  void onDatePicked(DateTime date) {
    dateController.text = _formatDate(date);
    dayController.text = _weekdays[date.weekday - 1];
  }

  /// Builds the domain entity from the current form values.
  AppointmentEntity buildAppointment({
    required String patientId,
    required String doctorId,
    required String doctorName,
  }) {
    return AppointmentEntity(
      id: '',
      patientId: patientId,
      patientName: nameController.text.trim(),
      patientPhone: phoneController.text.trim(),
      doctorId: doctorId,
      doctorName: doctorName,
      appointmentDay: dayController.text.trim(),
      appointmentDate: dateController.text.trim(),
    );
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  // ── Validators exposed so the page never writes validation logic inline ──

  String? Function(String?) get nameValidator =>
      (v) => Validators.required(v, 'Name');

  String? Function(String?) get phoneValidator => Validators.phone;

  String? Function(String?) get dateValidator =>
      (v) => Validators.required(v, 'Appointment date');

  String? Function(String?) get dayValidator =>
      (v) => Validators.required(v, 'Appointment day');

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    dayController.dispose();
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}
