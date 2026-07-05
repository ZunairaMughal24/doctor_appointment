import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/appointment_entity.dart';
import '../viewmodels/appointment_detail_viewmodel.dart';
import '../widgets/appointment_detail_widgets.dart';
import '../widgets/rating_bottom_sheet.dart';
import '../../../../core/widgets/custom_app_bar.dart';

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

  Future<void> _openRating() async {
    final result = await showModalBottomSheet<({int rating, String comment})>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RatingBottomSheet(doctorName: _vm.appointment.doctorName),
    );
    if (result == null || !mounted) return;
    await _vm.submitRating(
      context,
      rating: result.rating,
      comment: result.comment,
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
        appBar: CustomAppBar(
          title: 'Appointment',
          onBackPressed: () => Navigator.of(context).pop(_vm.changed),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                physics: const BouncingScrollPhysics(),
                children: [
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
                        AppointmentStatusBadge(status: _vm.appointment.effectiveStatus),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  AppointmentDetailRow(
                    icon: Icons.medical_information_outlined,
                    label: 'Type',
                    value: _vm.appointment.consultationType.label,
                  ),
                  AppointmentDetailRow(
                    icon: Icons.event_rounded,
                    label: 'Day',
                    value: _vm.appointment.appointmentDay,
                  ),
                  AppointmentDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: _vm.appointment.appointmentDate,
                  ),
                  if (_vm.appointment.appointmentTime.isNotEmpty)
                    AppointmentDetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Time slot',
                      value: _vm.appointment.appointmentTime,
                    ),
                  AppointmentDetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Full name',
                    value: _vm.appointment.patientName,
                  ),
                  AppointmentDetailRow(
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

  List<Widget> _actions() {
    final widgets = <Widget>[];
    if (_vm.isDoctorViewer) {
      widgets.addAll(_doctorActions());
    } else if (_vm.isPatientViewer) {
      widgets.addAll(_patientActions());
    }
    widgets.addAll(_videoAndCompletionSection(widgets.isNotEmpty));
    return widgets;
  }

  List<Widget> _doctorActions() {
    final status = _vm.appointment.effectiveStatus;
    if (status == AppointmentStatus.pending) {
      return [
        AppButton(
          label: 'Confirm Appointment',
          icon: Icons.check_circle_outline_rounded,
          loading: _vm.busy,
          onPressed: _vm.busy
              ? null
              : () => _vm.updateStatus(context, AppointmentStatus.confirmed, asDoctor: true),
        ),
        const SizedBox(height: 12),
        AppButton.outlined(
          label: 'Decline',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          onPressed: _vm.busy ? null : () => _vm.confirmCancel(context, asDoctor: true),
        ),
      ];
    }
    if (status == AppointmentStatus.confirmed) {
      return [
        AppButton(
          label: 'Mark as Completed',
          icon: Icons.task_alt_rounded,
          color: AppColors.success,
          loading: _vm.busy,
          onPressed: _vm.busy
              ? null
              : () => _vm.updateStatus(context, AppointmentStatus.completed, asDoctor: true),
        ),
        const SizedBox(height: 12),
        AppButton.outlined(
          label: 'Cancel Appointment',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          onPressed: _vm.busy ? null : () => _vm.confirmCancel(context, asDoctor: true),
        ),
      ];
    }
    return [];
  }

  List<Widget> _patientActions() {
    final status = _vm.appointment.effectiveStatus;
    if (status == AppointmentStatus.cancelled ||
        status == AppointmentStatus.completed) {
      return [];
    }
    return [
      AppButton.outlined(
        label: 'Cancel Appointment',
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        onPressed: _vm.busy ? null : () => _vm.confirmCancel(context, asDoctor: false),
      ),
    ];
  }

  List<Widget> _videoAndCompletionSection(bool hasPreceding) {
    final appt = _vm.appointment;
    final status = appt.effectiveStatus;
    final gap = hasPreceding ? [const SizedBox(height: 12)] : <Widget>[];

    if (appt.isJoinable) {
      return [
        ...gap,
        AppButton(
          label: 'Join on WhatsApp',
          icon: Icons.videocam_rounded,
          color: AppColors.success,
          onPressed: () => _vm.joinOnWhatsApp(context),
        ),
      ];
    }
    if (status == AppointmentStatus.completed) {
      return [...gap, ..._completedWidgets(appt)];
    }
    if (appt.isVideo &&
        appt.status == AppointmentStatus.confirmed &&
        appt.startsAt != null) {
      return [...gap, const AppointmentJoinHint()];
    }
    return [];
  }

  List<Widget> _completedWidgets(AppointmentEntity appt) {
    final alreadyRated = appt.hasRating || _vm.hasJustRated;
    return [
      const SessionCompletedBanner(),
      if (_vm.isPatientViewer) ...[
        const SizedBox(height: 12),
        if (alreadyRated)
          AppointmentRatingDisplay(
            rating: appt.hasRating ? appt.rating! : _vm.justRating,
            comment: appt.hasRating ? appt.ratingComment : _vm.justComment,
          )
        else
          AppButton(
            label: 'Rate Your Experience',
            icon: Icons.star_rounded,
            loading: _vm.ratingBusy,
            onPressed: _vm.ratingBusy ? null : _openRating,
          ),
      ],
    ];
  }
}
