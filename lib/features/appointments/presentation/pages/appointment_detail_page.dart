import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/current_session.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/app_button.dart';
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
    _vm = AppointmentDetailViewModel(
      appointment: widget.appointment,
      viewerUid: context.read<CurrentSession>().uid,
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
    final error = await _vm.submitRating(
      rating: result.rating,
      comment: result.comment,
    );
    if (error != null && mounted) {
      AppFeedback.showError(context, error);
    }
  }

  /// Runs a status update and shows the resulting success/error feedback.
  Future<void> _handleStatusUpdate(
    AppointmentStatus status, {
    required bool asDoctor,
  }) async {
    final result = await _vm.updateStatus(status, asDoctor: asDoctor);
    if (!mounted) return;
    if (result.ok) {
      AppFeedback.showSuccess(context, result.message);
    } else {
      AppFeedback.showError(context, result.message);
    }
  }

  /// Shows the cancel confirmation dialog, then applies the cancellation.
  Future<void> _confirmCancel({required bool asDoctor}) async {
    final ok = await AppFeedback.showConfirmation(
      context,
      title: 'Cancel appointment',
      message: 'Are you sure you want to cancel this appointment?',
      confirmLabel: 'Cancel appointment',
      cancelLabel: 'Keep it',
      isDanger: true,
    );
    if (ok && mounted) {
      await _handleStatusUpdate(AppointmentStatus.cancelled, asDoctor: asDoctor);
    }
  }

  Future<void> _joinOnWhatsApp() async {
    final error = await _vm.joinOnWhatsApp();
    if (error != null && mounted) {
      AppFeedback.showError(context, error);
    }
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
          title: 'Appointment Detail',
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
                    child: AppointmentHeaderAvatar(
                      icon: _vm.isDoctorViewer
                          ? Icons.person_rounded
                          : (isVideo
                              ? Icons.videocam_rounded
                              : Icons.medical_services_outlined),
                      name: _vm.isDoctorViewer
                          ? _vm.appointment.patientName
                          : _vm.appointment.doctorName,
                      status: _vm.appointment.effectiveStatus,
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (_vm.appointment.doctorSpeciality.isNotEmpty)
                    AppointmentDetailRow(
                      icon: Icons.local_hospital_outlined,
                      label: 'Speciality',
                      value: _vm.appointment.doctorSpeciality,
                    ),
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

  /// Assembles every action section (role-specific buttons, then the
  /// video/completion section), inserting a gap between sections that are
  /// actually non-empty. Each `_xxxSection` below only decides *what* to
  /// show — spacing between sections is decided here, once.
  List<Widget> _actions() {
    final sections = [
      if (_vm.isDoctorViewer)
        _doctorActions()
      else if (_vm.isPatientViewer)
        _patientActions(),
      _videoAndCompletionSection(),
    ].where((section) => section.isNotEmpty);

    final widgets = <Widget>[];
    for (final section in sections) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 12));
      widgets.addAll(section);
    }
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
              : () =>
                  _handleStatusUpdate(AppointmentStatus.confirmed, asDoctor: true),
        ),
        const SizedBox(height: 12),
        _cancelButton('Decline', asDoctor: true),
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
              : () =>
                  _handleStatusUpdate(AppointmentStatus.completed, asDoctor: true),
        ),
        const SizedBox(height: 12),
        _cancelButton('Cancel Appointment', asDoctor: true),
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
    return [_cancelButton('Cancel Appointment', asDoctor: false)];
  }

  Widget _cancelButton(String label, {required bool asDoctor}) {
    return AppButton.outlined(
      label: label,
      icon: Icons.cancel_outlined,
      color: AppColors.error,
      onPressed: _vm.busy ? null : () => _confirmCancel(asDoctor: asDoctor),
    );
  }

  List<Widget> _videoAndCompletionSection() {
    final appt = _vm.appointment;

    if (appt.isJoinable) {
      return [
        AppButton(
          label: 'Join on WhatsApp',
          icon: Icons.videocam_rounded,
          color: AppColors.success,
          onPressed: _joinOnWhatsApp,
        ),
      ];
    }
    if (appt.effectiveStatus == AppointmentStatus.completed) {
      return _completedWidgets();
    }
    if (appt.isVideo &&
        appt.status == AppointmentStatus.confirmed &&
        appt.startsAt != null) {
      return [const AppointmentJoinHint()];
    }
    return [];
  }

  List<Widget> _completedWidgets() {
    final appt = _vm.appointment;
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
