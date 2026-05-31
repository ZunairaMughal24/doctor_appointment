import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String appointmentDay;
  final String appointmentDate;

  const AppointmentEntity({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDay,
    required this.appointmentDate,
  });

  @override
  List<Object?> get props => [id];
}
