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
  });

  factory AppointmentModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      patientId: data['appointment_by_id'] ?? '',
      patientName: data['appointment_by_name'] ?? '',
      patientPhone: data['appointment_by_number'] ?? '',
      doctorId: data['appointment_with_id'] ?? '',
      doctorName: data['appointment_with_name'] ?? '',
      appointmentDay: data['appointment_day'] ?? '',
      appointmentDate: data['appointment_date'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'appointment_by_id': patientId,
        'appointment_by_name': patientName,
        'appointment_by_number': patientPhone,
        'appointment_with_id': doctorId,
        'appointment_with_name': doctorName,
        'appointment_day': appointmentDay,
        'appointment_date': appointmentDate,
      };
}
