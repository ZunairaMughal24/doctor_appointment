import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../domain/entities/weekly_availability.dart';

// ── Header ────────────────────────────────────────────────────────────────────

class DoctorHomeHeader extends StatelessWidget {
  final String name;
  const DoctorHomeHeader({super.key, required this.name});

  String _greeting() {
    final h = TimeOfDay.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).viewPadding.top;
    final now = DateTime.now();
    final weekday = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ][now.weekday - 1];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.headerVerticalGradientAlt,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(AppAssets.appLogo),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_greeting()},',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isNotEmpty ? 'Dr. ${name.split(' ').first}' : 'Doctor',
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$weekday, ${now.day} ${months[now.month - 1]} ${now.year}',
                  style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.normal, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats strip ───────────────────────────────────────────────────────────────

class DoctorStatsStrip extends StatelessWidget {
  final int pending;
  final int upcoming;
  final double rating;

  const DoctorStatsStrip({
    super.key,
    required this.pending,
    required this.upcoming,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      transform: Matrix4.translationValues(0, -20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatCell(
            value: '$pending',
            label: 'Pending',
            color: AppColors.warning,
            icon: Icons.schedule_rounded,
          ),
          const _VerticalDivider(),
          _StatCell(
            value: '$upcoming',
            label: 'Upcoming',
            color: AppColors.success,
            icon: Icons.event_available_rounded,
          ),
          const _VerticalDivider(),
          _StatCell(
            value: rating > 0 ? rating.toStringAsFixed(1) : '—',
            label: 'Rating',
            color: Colors.amber,
            icon: Icons.star_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCell({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                fontSize: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: AppColors.divider);
  }
}

// ── Dashboard section ─────────────────────────────────────────────────────────

class DoctorDashboardSection extends StatelessWidget {
  final String title;
  final int count;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<AppointmentEntity> appointments;

  const DoctorDashboardSection({
    super.key,
    required this.title,
    required this.count,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (count > 0)
                TextButton(
                  onPressed: () => context.push(AppRoutes.appointments),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: AppTextStyles.label
                        .copyWith(fontWeight: FontWeight.w600),
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('See all'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (appointments.isEmpty)
            _EmptyCard(message: emptyMessage, icon: emptyIcon)
          else
            ...appointments.map((a) => DoctorDashboardAppointmentCard(appointment: a)),
        ],
      ),
    );
  }
}

// ── Appointment card ──────────────────────────────────────────────────────────

class DoctorDashboardAppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;

  const DoctorDashboardAppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final status = appointment.effectiveStatus;
    final (Color color, IconData icon) = switch (status) {
      AppointmentStatus.pending =>
        (AppColors.warning, Icons.schedule_rounded),
      AppointmentStatus.confirmed =>
        (AppColors.success, Icons.check_circle_rounded),
      AppointmentStatus.completed =>
        (AppColors.primary, Icons.task_alt_rounded),
      AppointmentStatus.cancelled =>
        (AppColors.error, Icons.cancel_rounded),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(
          AppRoutes.appointmentDetail,
          extra: appointment,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${appointment.appointmentDay}  ·  ${appointment.appointmentDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (appointment.appointmentTime.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        WeeklyAvailability.to12h(appointment.appointmentTime),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyCard({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.primaryLight),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.label
                .copyWith(fontWeight: FontWeight.normal, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
