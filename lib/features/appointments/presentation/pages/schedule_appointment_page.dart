import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/di/injection_container.dart';
import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/core/utils/app_feedback.dart';
import 'package:fyp/core/widgets/app_button.dart';
import 'package:fyp/core/widgets/app_loader.dart';
import 'package:fyp/core/widgets/app_text_field.dart';
import 'package:fyp/features/appointments/domain/entities/appointment_entity.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_state.dart';
import 'package:fyp/features/appointments/presentation/cubit/slots_cubit.dart';
import 'package:fyp/features/appointments/presentation/viewmodels/schedule_appointment_viewmodel.dart';
import 'package:fyp/features/doctors/domain/entities/doctor_entity.dart';
import 'package:fyp/features/doctors/domain/entities/weekly_availability.dart';

class ScheduleAppointmentPage extends StatelessWidget {
  final DoctorEntity doctor;
  const ScheduleAppointmentPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SlotsCubit>(),
      child: _ScheduleView(doctor: doctor),
    );
  }
}

class _ScheduleView extends StatefulWidget {
  final DoctorEntity doctor;
  const _ScheduleView({required this.doctor});

  @override
  State<_ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<_ScheduleView> {
  late final ScheduleAppointmentViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ScheduleAppointmentViewModel(widget.doctor);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: Text(
          widget.doctor.name,
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
            // Booking may have failed because the slot was just taken —
            // refresh live availability so it greys out.
            _vm.refreshSlots(context);
          }
        },
        child: Form(
          key: _vm.formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              const _SectionLabel('Consultation type'),
              _ConsultationToggle(
                selected: _vm.consultationType,
                onChanged: (t) => setState(() => _vm.setConsultationType(t)),
              ),
              if (_vm.consultationType == ConsultationType.video) ...[
                const SizedBox(height: 10),
                const _VideoNote(),
              ],
              const SizedBox(height: 8),
              const _SectionLabel('Your name'),
              _Field(
                controller: _vm.nameController,
                hint: 'Enter your full name',
                validator: _vm.nameValidator,
              ),
              const _SectionLabel('Contact number'),
              _Field(
                controller: _vm.phoneController,
                hint: 'Enter your number',
                keyboardType: TextInputType.phone,
                validator: _vm.phoneValidator,
              ),
              const _SectionLabel('Appointment date'),
              _DateSelector(
                label: _vm.hasDate
                    ? '${_vm.selectedDay}, ${_vm.formattedDate}'
                    : 'Tap to pick a date',
                isPlaceholder: !_vm.hasDate,
                onTap: () async {
                  if (await _vm.pickDate(context) && mounted) setState(() {});
                },
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Available slots'),
              _SlotsArea(vm: _vm, onPick: (t) => setState(() => _vm.selectTime(t))),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) => _SubmitButton(
              loading: state is AppointmentLoading,
              onTap: () => _vm.submit(context),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Slots area: live availability from SlotsCubit ─────────────────────────────

class _SlotsArea extends StatelessWidget {
  final ScheduleAppointmentViewModel vm;
  final ValueChanged<String> onPick;
  const _SlotsArea({required this.vm, required this.onPick});

  @override
  Widget build(BuildContext context) {
    if (!vm.hasDate) {
      return const _Hint('Pick a date to see available time slots.');
    }
    if (vm.isClosedOnSelectedDay) {
      return _Hint('Dr. ${vm.doctor.name.replaceFirst('Dr. ', '')} '
          'is not available on ${vm.selectedDay}. Try another day.');
    }

    return BlocBuilder<SlotsCubit, SlotsState>(
      builder: (context, state) {
        if (state is SlotsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: AppLoader(dotSize: 9),
          );
        }
        if (state is SlotsError) {
          return _Hint('Could not load slots: ${state.message}');
        }

        final booked =
            state is SlotsLoaded ? state.bookedTimes : const <String>[];
        final slots = vm.slotsForSelectedDay;
        if (slots.isEmpty) {
          return const _Hint('No slots available on this day.');
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final slot in slots)
              _SlotChip(
                label: WeeklyAvailability.to12h(slot),
                isBooked: booked.contains(slot),
                isSelected: vm.selectedTime == slot,
                onTap: () => onPick(slot),
              ),
          ],
        );
      },
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String label;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback onTap;

  const _SlotChip({
    required this.label,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (isBooked) {
      bg = AppColors.divider;
      fg = AppColors.textHint;
    } else if (isSelected) {
      bg = AppColors.primary;
      fg = Colors.white;
    } else {
      bg = Colors.white;
      fg = AppColors.primary;
    }

    return Opacity(
      opacity: isBooked ? 0.7 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isBooked ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration:
                        isBooked ? TextDecoration.lineThrough : null,
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

// ── Consultation type toggle ──────────────────────────────────────────────────

class _ConsultationToggle extends StatelessWidget {
  final ConsultationType selected;
  final ValueChanged<ConsultationType> onChanged;
  const _ConsultationToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeOption(
            icon: Icons.medical_services_outlined,
            label: 'In-person',
            active: selected == ConsultationType.inPerson,
            onTap: () => onChanged(ConsultationType.inPerson),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeOption(
            icon: Icons.videocam_outlined,
            label: 'Video',
            active: selected == ConsultationType.video,
            onTap: () => onChanged(ConsultationType.video),
          ),
        ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TypeOption({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.inputBorder,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: active ? Colors.white : AppColors.primary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small shared widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 14, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _VideoNote extends StatelessWidget {
  const _VideoNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "You'll connect via WhatsApp video at your booked time. "
              'Start it from the appointment in "My Appointments".',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final bool isPlaceholder;
  final VoidCallback onTap;
  const _DateSelector({
    required this.label,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isPlaceholder
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                  fontWeight:
                      isPlaceholder ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _SubmitButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Confirm Appointment',
      icon: Icons.event_available_rounded,
      loading: loading,
      onPressed: onTap,
    );
  }
}
