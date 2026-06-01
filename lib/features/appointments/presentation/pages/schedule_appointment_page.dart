import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/core/utils/app_feedback.dart';
import 'package:fyp/core/utils/app_pickers.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_state.dart';
import 'package:fyp/features/appointments/presentation/viewmodels/schedule_appointment_viewmodel.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  final String docId;
  final String name;

  const ScheduleAppointmentPage({
    super.key,
    required this.docId,
    required this.name,
  });

  @override
  State<ScheduleAppointmentPage> createState() =>
      _ScheduleAppointmentPageState();
}

/// Thin view — owns no logic.
/// All form state, date formatting, and entity construction live in the ViewModel.
class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  late final ScheduleAppointmentViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ScheduleAppointmentViewModel();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _openDatePicker() async {
    final picked = await AppPickers.pickDate(context);
    if (picked != null) _vm.onDatePicked(picked);
  }

  String get _currentUid {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.uid : '';
  }

  void _submit() {
    if (!_vm.validate()) return;
    context.read<AppointmentBloc>().add(
          BookAppointment(
            _vm.buildAppointment(
              patientId: _currentUid,
              doctorId: widget.docId,
              doctorName: widget.name,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentBooked) {
            AppFeedback.showSuccess(context, 'Appointment booked successfully!');
            context.go(AppRoutes.appointments);
          } else if (state is AppointmentError) {
            AppFeedback.showError(context, state.message);
          }
        },
        child: Container(
          color: AppColors.background,
          child: Form(
            key: _vm.formKey,
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _AppointmentFormField(
                  label: 'Name',
                  controller: _vm.nameController,
                  hint: 'Enter your full name',
                  validator: _vm.nameValidator,
                ),
                _AppointmentFormField(
                  label: 'Contact number',
                  controller: _vm.phoneController,
                  hint: 'Enter number',
                  keyboardType: TextInputType.phone,
                  validator: _vm.phoneValidator,
                ),
                _AppointmentFormField(
                  label: 'Appointment date',
                  controller: _vm.dateController,
                  hint: 'Tap to pick a date',
                  readOnly: true,
                  onTap: _openDatePicker,
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  validator: _vm.dateValidator,
                ),
                _AppointmentFormField(
                  label: 'Appointment day',
                  controller: _vm.dayController,
                  hint: 'Auto-filled when you pick a date',
                  readOnly: true,
                  validator: _vm.dayValidator,
                ),
                const SizedBox(height: 32),
                BlocBuilder<AppointmentBloc, AppointmentState>(
                  builder: (context, state) => _SubmitButton(
                    loading: state is AppointmentLoading,
                    onTap: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _AppointmentFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AppointmentFormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 12, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            hintStyle:
                const TextStyle(fontSize: 14, color: AppColors.textHint),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _SubmitButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 53,
          child: Center(
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Confirm Appointment',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}
