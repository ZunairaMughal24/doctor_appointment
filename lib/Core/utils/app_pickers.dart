import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';

/// Centralises all system picker calls so pages never hard-code
/// theme overrides, date ranges, or picker config.
class AppPickers {
  AppPickers._();

  /// Opens a date picker themed to the app palette.
  /// Returns the chosen [DateTime], or `null` if the user dismissed.
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now.add(const Duration(days: 1)),
      firstDate: firstDate ?? now,
      lastDate: lastDate ?? now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
  }

  /// Opens a time picker themed to the app palette.
  /// Returns the chosen [TimeOfDay], or `null` if dismissed.
  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
  }
}
