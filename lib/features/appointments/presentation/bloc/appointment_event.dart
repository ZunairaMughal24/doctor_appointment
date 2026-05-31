import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserAppointments extends AppointmentEvent {
  final String patientId;
  const LoadUserAppointments(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class LoadDoctorAppointments extends AppointmentEvent {
  final String doctorId;
  const LoadDoctorAppointments(this.doctorId);
  @override
  List<Object?> get props => [doctorId];
}

class BookAppointment extends AppointmentEvent {
  final AppointmentEntity appointment;
  const BookAppointment(this.appointment);
  @override
  List<Object?> get props => [appointment];
}
