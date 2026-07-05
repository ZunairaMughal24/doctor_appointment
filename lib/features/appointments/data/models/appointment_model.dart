import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.patientPhone,
    required super.doctorId,
    required super.doctorName,
    required super.appointmentDay,
    required super.appointmentDate,
    super.doctorPhone,
    super.doctorSpeciality,
    super.appointmentTime,
    super.consultationType,
    super.status,
    super.createdAt,
    super.rating,
    super.ratingComment,
  });

  factory AppointmentModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    final ts = data['created_at'];
    return AppointmentModel(
      id: id,
      patientId: data['appointment_by_id'] ?? '',
      patientName: data['appointment_by_name'] ?? '',
      patientPhone: data['appointment_by_number'] ?? '',
      doctorId: data['appointment_with_id'] ?? '',
      doctorName: data['appointment_with_name'] ?? '',
      doctorPhone: data['appointment_with_number'] ?? '',
      doctorSpeciality: data['appointment_with_speciality'] ?? '',
      appointmentDay: data['appointment_day'] ?? '',
      appointmentDate: data['appointment_date'] ?? '',
      appointmentTime: data['appointment_time'] ?? '',
      consultationType:
          ConsultationTypeX.fromKey(data['consultation_type'] as String?),
      // Legacy records without a status default to confirmed (they predate the
      // approval workflow, so treat them as already-active rather than pending).
      status: data.containsKey('status')
          ? AppointmentStatusX.fromKey(data['status'] as String?)
          : AppointmentStatus.confirmed,
      createdAt: ts is Timestamp ? ts.toDate() : null,
      rating: data['rating'] as int?,
      ratingComment: data['rating_comment'] as String? ?? '',
    );
  }

  /// Firestore payload for a *new* booking. The server stamps `created_at`.
  Map<String, dynamic> toFirestore() => {
        'appointment_by_id': patientId,
        'appointment_by_name': patientName,
        'appointment_by_number': patientPhone,
        'appointment_with_id': doctorId,
        'appointment_with_name': doctorName,
        'appointment_with_number': doctorPhone,
        'appointment_with_speciality': doctorSpeciality,
        'appointment_day': appointmentDay,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'consultation_type': consultationType.key,
        'status': status.key,
        'created_at': FieldValue.serverTimestamp(),
      };
}
