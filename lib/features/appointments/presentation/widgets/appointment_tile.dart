import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_container.dart';
import '../../domain/entities/appointment_entity.dart';

/// Single appointment row used in MyAppointmentsPage.
class AppointmentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String speciality;
  final bool isPatient;
  final AppointmentStatus status;
  final VoidCallback onTap;

  const AppointmentTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.speciality = '',
    this.isPatient = true,
    this.status = AppointmentStatus.pending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              isPatient ? Icons.medical_services_rounded : Icons.person,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (speciality.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const SizedBox(width: 3),
                      Text(
                        speciality,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.normal,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: status),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AppointmentStatus.pending => AppColors.warning,
      AppointmentStatus.confirmed => AppColors.success,
      AppointmentStatus.cancelled => AppColors.error,
      AppointmentStatus.completed => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Centered empty-state placeholder.
class AppointmentEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppointmentEmptyState({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.primaryLight),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
