import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/constants/app_text_styles.dart';
import 'package:medic/core/widgets/app_button.dart';
import 'package:medic/core/widgets/app_loader.dart';
import 'package:medic/core/widgets/app_text_field.dart';
import 'package:medic/features/appointments/domain/entities/appointment_entity.dart';
import 'package:medic/features/appointments/presentation/cubit/slots_cubit.dart';
import 'package:medic/features/appointments/presentation/viewmodels/schedule_appointment_viewmodel.dart';
import 'package:medic/features/doctors/domain/entities/weekly_availability.dart';

class ScheduleSlotsArea extends StatelessWidget {
  final ScheduleAppointmentViewModel vm;
  final ValueChanged<String> onPick;
  const ScheduleSlotsArea({super.key, required this.vm, required this.onPick});

  @override
  Widget build(BuildContext context) {
    if (!vm.hasDate) {
      return const ScheduleHint('Pick a date to see available time slots.');
    }
    if (vm.isClosedOnSelectedDay) {
      return ScheduleHint('Dr. ${vm.doctor.name.replaceFirst('Dr. ', '')} '
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
          return ScheduleHint('Could not load slots: ${state.message}');
        }

        final booked =
            state is SlotsLoaded ? state.bookedTimes : const <String>[];
        final slots = vm.slotsForSelectedDay;
        if (slots.isEmpty) {
          return const ScheduleHint('No slots available on this day.');
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final slot in slots)
              ScheduleSlotChip(
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

class ScheduleSlotChip extends StatelessWidget {
  final String label;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback onTap;

  const ScheduleSlotChip({
    super.key,
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
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isBooked ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: fg,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                decoration: isBooked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConsultationToggle extends StatelessWidget {
  final ConsultationType selected;
  final ValueChanged<ConsultationType> onChanged;
  const ConsultationToggle(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ConsultationTypeOption(
            icon: Icons.medical_services_outlined,
            label: 'In-person',
            active: selected == ConsultationType.inPerson,
            onTap: () => onChanged(ConsultationType.inPerson),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ConsultationTypeOption(
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

class ConsultationTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const ConsultationTypeOption({
    super.key,
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
      clipBehavior: Clip.antiAlias,
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
                style: AppTextStyles.label.copyWith(
                  color: active ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleSectionLabel extends StatelessWidget {
  final String text;
  const ScheduleSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 14, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class VideoConsultationNote extends StatelessWidget {
  const VideoConsultationNote({super.key});

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
        children: [
          const Icon(Icons.info_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "You'll connect via WhatsApp video at your booked time. "
              'Start it from the appointment in "My Appointments".',
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.normal,
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

class ScheduleHint extends StatelessWidget {
  final String text;
  const ScheduleHint(this.text, {super.key});

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
        style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.normal, color: AppColors.textSecondary),
      ),
    );
  }
}

class ScheduleDateSelector extends StatelessWidget {
  final String label;
  final bool isPlaceholder;
  final VoidCallback onTap;
  const ScheduleDateSelector({
    super.key,
    required this.label,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
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
              const Icon(Icons.calendar_today,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
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

class ScheduleField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator;

  const ScheduleField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
    );
  }
}

class ScheduleSubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const ScheduleSubmitButton(
      {super.key, required this.loading, required this.onTap});

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
