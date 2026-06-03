import 'package:flutter/material.dart';
import 'package:fyp/core/utils/validators.dart';
import 'package:fyp/features/appointments/domain/entities/appointment_entity.dart';
import 'package:fyp/features/doctors/domain/entities/doctor_entity.dart';

/// Holds all non-UI state/logic for the schedule-appointment form.
/// The page mutates this via setState and reads it during build.
class ScheduleAppointmentViewModel {
  final DoctorEntity doctor;
  ScheduleAppointmentViewModel(this.doctor);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  DateTime? selectedDate;
  String selectedDay = '';
  String? selectedTime;
  ConsultationType consultationType = ConsultationType.inPerson;

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  bool get hasDate => selectedDate != null;
  bool get hasTime => selectedTime != null;

  /// The doctor's slot labels for the selected weekday (empty if none/closed).
  List<String> get slotsForSelectedDay =>
      hasDate ? doctor.schedule.slotsFor(selectedDay) : const [];

  bool get isClosedOnSelectedDay =>
      hasDate && !doctor.schedule.isOpenOn(selectedDay);

  String get formattedDate => hasDate ? _formatDate(selectedDate!) : '';

  // ── Mutations (called inside setState by the page) ──────────────────────────

  void onDatePicked(DateTime date) {
    selectedDate = date;
    selectedDay = _weekdays[date.weekday - 1];
    selectedTime = null; // reset slot when the date changes
  }

  void selectTime(String time) => selectedTime = time;

  void setConsultationType(ConsultationType type) => consultationType = type;

  // ── Validation ──────────────────────────────────────────────────────────────

  bool validateFields() => formKey.currentState?.validate() ?? false;

  String? Function(String?) get nameValidator =>
      (v) => Validators.required(v, 'Name');

  String? Function(String?) get phoneValidator => Validators.phone;

  /// Builds the domain entity from the current selections.
  AppointmentEntity buildAppointment({required String patientId}) {
    return AppointmentEntity(
      id: '',
      patientId: patientId,
      patientName: nameController.text.trim(),
      patientPhone: phoneController.text.trim(),
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorPhone: doctor.phoneNumber,
      appointmentDay: selectedDay,
      appointmentDate: formattedDate,
      appointmentTime: selectedTime ?? '',
      consultationType: consultationType,
    );
  }

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}
