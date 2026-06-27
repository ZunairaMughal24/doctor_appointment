import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/communication_launcher.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/usecases/submit_rating_usecase.dart';
import '../../domain/usecases/update_appointment_status_usecase.dart';

/// Presentation logic + mutable state for the appointment detail screen, so the
/// page stays pure UI. [onChange] is invoked whenever state changes so the
/// hosting widget can rebuild.
class AppointmentDetailViewModel {
  AppointmentDetailViewModel({
    required AppointmentEntity appointment,
    required this.viewerUid,
    required this.onChange,
  }) : _appt = appointment;

  final String viewerUid;
  final VoidCallback onChange;

  AppointmentEntity _appt;
  bool _busy = false;
  bool _changed = false;
  bool _ratingBusy = false;
  bool _hasJustRated = false;
  int _justRating = 0;
  String _justComment = '';

  AppointmentEntity get appointment => _appt;
  bool get busy => _busy;
  bool get changed => _changed;
  bool get ratingBusy => _ratingBusy;
  bool get hasJustRated => _hasJustRated;
  int get justRating => _justRating;
  String get justComment => _justComment;

  bool get isDoctorViewer =>
      viewerUid.isNotEmpty && viewerUid == _appt.doctorId;
  bool get isPatientViewer =>
      viewerUid.isNotEmpty && viewerUid == _appt.patientId;

  /// WhatsApp/contact target depends on the viewer: a doctor contacts the
  /// patient, a patient contacts the doctor.
  String get contactPhone =>
      isDoctorViewer ? _appt.patientPhone : _appt.doctorPhone;

  void _set(VoidCallback fn) {
    fn();
    onChange();
  }

  Future<void> updateStatus(
    BuildContext context,
    AppointmentStatus status, {
    required bool asDoctor,
  }) async {
    _set(() => _busy = true);
    final result = await sl<UpdateAppointmentStatusUseCase>()(
      UpdateStatusParams(
        appointmentId: _appt.id,
        status: status,
        actorIsDoctor: asDoctor,
      ),
    );
    result.fold(
      (failure) {
        _set(() => _busy = false);
        if (context.mounted) {
          AppFeedback.showError(context, failure.userMessage);
        }
      },
      (_) {
        _set(() {
          _appt = _appt.copyWith(status: status);
          _busy = false;
          _changed = true;
        });
        if (context.mounted) {
          AppFeedback.showSuccess(
            context,
            switch (status) {
              AppointmentStatus.confirmed => 'Appointment confirmed.',
              AppointmentStatus.completed => 'Appointment marked as completed.',
              _ => 'Appointment cancelled.',
            },
          );
        }
      },
    );
  }

  Future<void> confirmCancel(
    BuildContext context, {
    required bool asDoctor,
  }) async {
    final ok = await AppFeedback.showConfirmation(
      context,
      title: 'Cancel appointment',
      message: 'Are you sure you want to cancel this appointment?',
      confirmLabel: 'Cancel appointment',
      cancelLabel: 'Keep it',
      isDanger: true,
    );
    if (ok && context.mounted) {
      await updateStatus(context, AppointmentStatus.cancelled,
          asDoctor: asDoctor);
    }
  }

  Future<void> submitRating(
    BuildContext context, {
    required int rating,
    required String comment,
  }) async {
    _set(() => _ratingBusy = true);
    final result = await sl<SubmitRatingUseCase>()(SubmitRatingParams(
      appointmentId: _appt.id,
      doctorId: _appt.doctorId,
      rating: rating,
      comment: comment,
    ));
    result.fold(
      (failure) {
        _set(() => _ratingBusy = false);
        if (context.mounted) {
          AppFeedback.showError(context, failure.userMessage);
        }
      },
      (_) {
        _set(() {
          _ratingBusy = false;
          _hasJustRated = true;
          _justRating = rating;
          _justComment = comment;
        });
      },
    );
  }

  Future<void> joinOnWhatsApp(BuildContext context) async {
    final asDoctor = isDoctorViewer;
    final phone = contactPhone;
    final greeting = asDoctor
        ? 'Hello ${_appt.patientName}'
        : 'Hello Dr. ${_appt.doctorName.replaceFirst('Dr. ', '')}';

    debugPrint(
        '[Join/WhatsApp] tapped — viewer=${asDoctor ? 'doctor' : 'patient'} '
        'uid=$viewerUid apptId=${_appt.id}');
    debugPrint('[Join/WhatsApp] contacting ${asDoctor ? 'patient' : 'doctor'} '
        'phone="$phone" (doctorPhone="${_appt.doctorPhone}", '
        'patientPhone="${_appt.patientPhone}")');

    final ok = await CommunicationLauncher.whatsApp(
      phone,
      message: '$greeting, '
          "I'm ready for our video consultation "
          '(${_appt.appointmentDay}, ${_appt.appointmentTime}).',
    );
    debugPrint('[Join/WhatsApp] launch result ok=$ok');
    if (!ok && context.mounted) {
      AppFeedback.showError(
          context, 'Could not open WhatsApp. Make sure it is installed.');
    }
  }
}
