import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/appointment_entity.dart';
import '../viewmodels/appointment_detail_viewmodel.dart';

/// Clean, appointment detail view: Status changes are persisted immediately and the screen
/// returns `true` on pop so the list can refresh.
class AppointmentDetailPage extends StatefulWidget {
  final AppointmentEntity appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late final AppointmentDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    final s = context.read<AuthBloc>().state;
    final uid = s is AuthAuthenticated ? s.user.uid : '';
    _vm = AppointmentDetailViewModel(
      appointment: widget.appointment,
      viewerUid: uid,
      onChange: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _vm.appointment.isVideo;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_vm.changed);
      },
      child: Scaffold(
        backgroundColor: AppColors.cardBg,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: AppColors.primary,
          titleSpacing: 4,
          leading: Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(_vm.changed),
                )
              : null,
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
                          _vm.appointment.doctorName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _StatusBadge(status: _vm.appointment.effectiveStatus),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Detail rows ─────────────────────────────────────────
                  _DetailRow(
                    icon: Icons.medical_information_outlined,
                    label: 'Type',
                    value: _vm.appointment.consultationType.label,
                  ),
                  _DetailRow(
                    icon: Icons.event_rounded,
                    label: 'Day',
                    value: _vm.appointment.appointmentDay,
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: _vm.appointment.appointmentDate,
                  ),
                  if (_vm.appointment.appointmentTime.isNotEmpty)
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time slot',
                      value: _vm.appointment.appointmentTime,
                    ),
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Full name',
                    value: _vm.appointment.patientName,
                  ),
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Contact number',
                    value: _vm.appointment.patientPhone,
                    isLast: true,
                  ),

                  const SizedBox(height: 28),
                  ..._actions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Role- and status-aware action buttons.
  List<Widget> _actions() {
    final widgets = <Widget>[];
    final appt = _vm.appointment;
    final status = appt.effectiveStatus;

    if (_vm.isDoctorViewer) {
      if (status == AppointmentStatus.pending) {
        widgets.add(AppButton(
          label: 'Confirm Appointment',
          icon: Icons.check_circle_outline_rounded,
          loading: _vm.busy,
          onPressed: _vm.busy
              ? null
              : () => _vm.updateStatus(context, AppointmentStatus.confirmed,
                  asDoctor: true),
        ));
        widgets.add(const SizedBox(height: 12));
        widgets.add(AppButton.outlined(
          label: 'Decline',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          onPressed: _vm.busy
              ? null
              : () => _vm.confirmCancel(context, asDoctor: true),
        ));
      } else if (status == AppointmentStatus.confirmed) {
        widgets.add(AppButton.outlined(
          label: 'Cancel Appointment',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          onPressed: _vm.busy
              ? null
              : () => _vm.confirmCancel(context, asDoctor: true),
        ));
      }
    } else if (_vm.isPatientViewer &&
        status != AppointmentStatus.cancelled &&
        status != AppointmentStatus.completed) {
      widgets.add(AppButton.outlined(
        label: 'Cancel Appointment',
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        onPressed:
            _vm.busy ? null : () => _vm.confirmCancel(context, asDoctor: false),
      ));
    }

    // Join (WhatsApp video) — only for a confirmed video appointment whose
    // start time has arrived and whose window hasn't ended. Otherwise surface
    // the completed state or a "not yet" hint. No direct contact is offered
    // outside this confirmed, active window.
    if (appt.isJoinable) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 12));
      widgets.add(AppButton(
        label: 'Join on WhatsApp',
        icon: Icons.videocam_rounded,
        color: AppColors.success,
        onPressed: () => _vm.joinOnWhatsApp(context),
      ));
    } else if (status == AppointmentStatus.completed) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 12));
      widgets.add(const _SessionCompletedBanner());
    } else if (appt.isVideo &&
        appt.status == AppointmentStatus.confirmed &&
        appt.startsAt != null) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 12));
      widgets.add(const _JoinHint());
    }

    return widgets;
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (status) {
      AppointmentStatus.pending => (AppColors.warning, Icons.schedule_rounded),
      AppointmentStatus.confirmed => (
          AppColors.success,
          Icons.check_circle_rounded
        ),
      AppointmentStatus.cancelled => (AppColors.error, Icons.cancel_rounded),
      AppointmentStatus.completed => (
          AppColors.primary,
          Icons.task_alt_rounded
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when a confirmed appointment's window has passed.
class _SessionCompletedBanner extends StatelessWidget {
  const _SessionCompletedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.task_alt_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Session completed — this appointment has ended.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown for a confirmed video appointment before its start time arrives.
class _JoinHint extends StatelessWidget {
  const _JoinHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'The video join button will appear at your appointment time.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 16),
              // Expanded + wrap so long values (names, locations) never overflow.
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  textAlign: TextAlign.right,
                  softWrap: true,
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
