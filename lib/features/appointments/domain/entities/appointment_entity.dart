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
  });

  bool get isVideo => consultationType == ConsultationType.video;

  @override
  List<Object?> get props => [id];
}
