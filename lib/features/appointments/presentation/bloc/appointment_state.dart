import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();
  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

class AppointmentsLoaded extends AppointmentState {
  final List<AppointmentEntity> appointments;
  const AppointmentsLoaded(this.appointments);
  @override
  List<Object?> get props => [appointments];
}

class AppointmentBooked extends AppointmentState {
  const AppointmentBooked();
}

class AppointmentError extends AppointmentState {
  final String message;
  const AppointmentError(this.message);
  @override
  List<Object?> get props => [message];
}
