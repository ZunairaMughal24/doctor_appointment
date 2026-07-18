import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/weekly_availability_field.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';

class ProfileAvailabilitySection extends StatelessWidget {
  final WeeklyAvailability schedule;
  final bool enabled;
  final ValueChanged<WeeklyAvailability> onChanged;

  const ProfileAvailabilitySection({
    super.key,
    required this.schedule,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              'Weekly Availability',
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          WeeklyAvailabilityField(
            value: schedule,
            onChanged: onChanged,
            enabled: enabled,
          ),
        ],
      ),
    );
  }
}

class ProfileLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<String>? options;

  const ProfileLabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.enabled,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          if (options != null)
            AppDropdownField(
              controller: controller,
              hint: label,
              prefixIcon: icon,
              enabled: enabled,
              options: options!,
              validator: validator,
            )
          else
            AppTextField(
              controller: controller,
              hint: label,
              prefixIcon: icon,
              enabled: enabled,
              maxLines: maxLines,
              maxLength: maxLength,
              keyboardType: keyboardType,
              validator: validator,
            ),
        ],
      ),
    );
  }
}

