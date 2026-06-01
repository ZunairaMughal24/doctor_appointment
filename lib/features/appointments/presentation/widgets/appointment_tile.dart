import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_container.dart';

/// Single appointment row used in MyAppointmentsPage.
class AppointmentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPatient;
  final VoidCallback onTap;

  const AppointmentTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.isPatient = false,
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
              isPatient ? Icons.person : Icons.medical_services_outlined,
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
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
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
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
