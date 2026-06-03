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
enum AppointmentStatus { pending, confirmed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label => switch (this) {
        AppointmentStatus.pending => 'Pending',
        AppointmentStatus.confirmed => 'Confirmed',
        AppointmentStatus.cancelled => 'Cancelled',
      };

  /// Stable string for Firestore (matches the enum name).
  String get key => name;

  static AppointmentStatus fromKey(String? key) => switch (key) {
        'confirmed' => AppointmentStatus.confirmed,
        'cancelled' => AppointmentStatus.cancelled,
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
  });

  bool get isVideo => consultationType == ConsultationType.video;
  bool get isCancelled => status == AppointmentStatus.cancelled;

  AppointmentEntity copyWith({AppointmentStatus? status}) {
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
    );
  }

  // status included so a confirm/cancel change is treated as a distinct state.
  @override
  List<Object?> get props => [id, status];
}
