import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/communication_launcher.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/appointment_entity.dart';

/// Clean, minimal appointment detail view — a simple summary header followed by
/// label/value rows separated by thin dividers (no heavy boxed cards).
class AppointmentDetailPage extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isVideo = appointment.isVideo;

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          'Appointment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Summary header ──────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(
                          isVideo
                              ? Icons.videocam_rounded
                              : Icons.medical_services_outlined,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        appointment.doctorName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _StatusPill(
                        label: appointment.consultationType.label,
                        icon: isVideo
                            ? Icons.videocam_rounded
                            : Icons.medical_services_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Detail rows ─────────────────────────────────────────
                _DetailRow(
                  icon: Icons.event_rounded,
                  label: 'Day',
                  value: appointment.appointmentDay,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: appointment.appointmentDate,
                ),
                if (appointment.appointmentTime.isNotEmpty)
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time slot',
                    value: appointment.appointmentTime,
                  ),
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Full name',
                  value: appointment.patientName,
                ),
                _DetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Contact number',
                  value: appointment.patientPhone,
                  isLast: true,
                ),

                // ── Video join action ───────────────────────────────────
                if (isVideo && appointment.doctorPhone.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Join on WhatsApp',
                    icon: Icons.videocam_rounded,
                    color: AppColors.success,
                    onPressed: () async {
                      final ok = await CommunicationLauncher.whatsApp(
                        appointment.doctorPhone,
                        message:
                            'Hello Dr. ${appointment.doctorName.replaceFirst('Dr. ', '')}, '
                            "I'm ready for our video consultation "
                            '(${appointment.appointmentDay}, ${appointment.appointmentTime}).',
                      );
                      if (!ok && context.mounted) {
                        AppFeedback.showError(context,
                            'Could not open WhatsApp. Make sure it is installed.');
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatusPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value.isEmpty ? '—' : value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
