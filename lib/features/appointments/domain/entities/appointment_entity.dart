import 'package:equatable/equatable.dart';

/// How the appointment is conducted.
enum ConsultationType { inPerson, video }

extension ConsultationTypeX on ConsultationType {
  String get label =>
      this == ConsultationType.video ? 'Video Consultation' : 'In-person Visit';

  /// Stable string for Firestore.
  String get key => this == ConsultationType.video ? 'video' : 'in_person';

  static ConsultationType fromKey(String? key) =>
      key == 'video' ? ConsultationType.video : ConsultationType.inPerson;
}

/// Lifecycle of an appointment. A new booking starts [pending]; the doctor
/// then [confirmed]s or either party [cancelled]s it.
enum AppointmentStatus { pending, confirmed, cancelled, completed }

extension AppointmentStatusX on AppointmentStatus {
  String get label => switch (this) {
        AppointmentStatus.pending => 'Pending',
        AppointmentStatus.confirmed => 'Confirmed',
        AppointmentStatus.cancelled => 'Cancelled',
        AppointmentStatus.completed => 'Completed',
      };

  /// Stable string for Firestore (matches the enum name).
  String get key => name;

  static AppointmentStatus fromKey(String? key) => switch (key) {
        'confirmed' => AppointmentStatus.confirmed,
        'cancelled' => AppointmentStatus.cancelled,
        'completed' => AppointmentStatus.completed,
        _ => AppointmentStatus.pending,
      };
}

class AppointmentEntity extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;

  /// Doctor's phone — stored so a patient can reach them (e.g. WhatsApp).
  final String doctorPhone;

  final String appointmentDay;
  final String appointmentDate;

  /// Booked slot, 24-hour 'HH:mm' (e.g. '10:00'). Empty for legacy records.
  final String appointmentTime;

  final ConsultationType consultationType;

  /// Booking lifecycle status. Defaults to [AppointmentStatus.pending].
  final AppointmentStatus status;

  /// When the booking was created (used for sorting). Null for legacy records.
  final DateTime? createdAt;

  /// Star rating 1–5 submitted by the patient after the appointment ends.
  final int? rating;

  /// Optional comment submitted alongside the star rating.
  final String ratingComment;

  const AppointmentEntity({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDay,
    required this.appointmentDate,
    this.doctorPhone = '',
    this.appointmentTime = '',
    this.consultationType = ConsultationType.inPerson,
    this.status = AppointmentStatus.pending,
    this.createdAt,
    this.rating,
    this.ratingComment = '',
  });

  bool get isVideo => consultationType == ConsultationType.video;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  bool get hasRating => rating != null;

  /// A consultation session is assumed to run this long from its start time.
  static const Duration _sessionLength = Duration(minutes: 60);

  /// Scheduled start parsed from 'dd/MM/yyyy' + 'HH:mm'. Null if either is
  /// missing/malformed (e.g. legacy records without a time).
  DateTime? get startsAt {
    if (appointmentDate.isEmpty || appointmentTime.isEmpty) return null;
    final d = appointmentDate.split('/');
    final t = appointmentTime.split(':');
    if (d.length != 3 || t.length < 2) return null;
    final day = int.tryParse(d[0]);
    final month = int.tryParse(d[1]);
    final year = int.tryParse(d[2]);
    final hour = int.tryParse(t[0]);
    final minute = int.tryParse(t[1]);
    if (day == null ||
        month == null ||
        year == null ||
        hour == null ||
        minute == null) {
      return null;
    }
    return DateTime(year, month, day, hour, minute);
  }

  DateTime? get endsAt => startsAt?.add(_sessionLength);

  /// The scheduled session window has fully passed.
  bool get hasEnded {
    final e = endsAt;
    return e != null && DateTime.now().isAfter(e);
  }

  /// WhatsApp video join is available only for a confirmed video appointment
  /// whose start time has arrived and whose window hasn't ended.
  bool get isJoinable {
    final s = startsAt;
    return isVideo &&
        status == AppointmentStatus.confirmed &&
        s != null &&
        !DateTime.now().isBefore(s) &&
        !hasEnded;
  }

  /// Status to *display*: a confirmed appointment whose window has passed reads
  /// as completed even before the persisted status catches up.
  AppointmentStatus get effectiveStatus =>
      (status == AppointmentStatus.confirmed && hasEnded)
          ? AppointmentStatus.completed
          : status;

  /// A confirmed appointment whose window ended and should be persisted as
  /// completed on the next load.
  bool get shouldAutoComplete =>
      status == AppointmentStatus.confirmed && hasEnded;

  AppointmentEntity copyWith({
    AppointmentStatus? status,
    int? rating,
    String? ratingComment,
  }) {
    return AppointmentEntity(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorPhone: doctorPhone,
      appointmentDay: appointmentDay,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      consultationType: consultationType,
      status: status ?? this.status,
      createdAt: createdAt,
      rating: rating ?? this.rating,
      ratingComment: ratingComment ?? this.ratingComment,
    );
  }

  @override
  List<Object?> get props => [id, status, rating];
}
