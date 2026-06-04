import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/core/utils/app_feedback.dart';
import 'package:fyp/core/utils/app_pickers.dart';
import 'package:fyp/core/utils/validators.dart';
import 'package:fyp/features/appointments/domain/entities/appointment_entity.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:fyp/features/appointments/presentation/cubit/slots_cubit.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';
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

  // ── Coordination (context-bound) ─────────────────────────────────────────────

  String _uid(BuildContext context) {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.uid : '';
  }

  /// Shows the date picker, updates selection and refreshes live availability.
  /// Returns true if a date was chosen so the page can rebuild.
  Future<bool> pickDate(BuildContext context) async {
    final picked = await AppPickers.pickDate(context);
    if (picked == null) return false;
    onDatePicked(picked);
    if (context.mounted) _loadSlots(context);
    return true;
  }

  /// Reloads availability for the selected date (e.g. after a failed booking
  /// because a slot was just taken).
  void refreshSlots(BuildContext context) {
    if (hasDate) _loadSlots(context);
  }

  void _loadSlots(BuildContext context) {
    context
        .read<SlotsCubit>()
        .loadBookedTimes(doctorId: doctor.id, date: formattedDate);
  }

  /// Validates the form and dispatches the booking. Shows inline errors for the
  /// missing pieces.
  void submit(BuildContext context) {
    if (_uid(context).isEmpty) {
      AppFeedback.showError(context, 'Please sign in to book an appointment.');
      return;
    }
    if (!validateFields()) return;
    if (!hasDate) {
      AppFeedback.showError(context, 'Please select an appointment date.');
      return;
    }
    if (!hasTime) {
      AppFeedback.showError(context, 'Please select an available time slot.');
      return;
    }
    context
        .read<AppointmentBloc>()
        .add(BookAppointment(buildAppointment(patientId: _uid(context))));
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
