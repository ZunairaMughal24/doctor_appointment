import 'package:equatable/equatable.dart';
import '../../domain/entities/doctor_entity.dart';

abstract class DoctorState extends Equatable {
  const DoctorState();
  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {
  const DoctorInitial();
}

class DoctorLoading extends DoctorState {
  const DoctorLoading();
}

class DoctorsLoaded extends DoctorState {
  final List<DoctorEntity> doctors;
  const DoctorsLoaded(this.doctors);
  @override
  List<Object?> get props => [doctors];
}

class DoctorDetailLoaded extends DoctorState {
  final DoctorEntity doctor;
  const DoctorDetailLoaded(this.doctor);
  @override
  List<Object?> get props => [doctor];
}

class DoctorError extends DoctorState {
  final String message;
  const DoctorError(this.message);
  @override
  List<Object?> get props => [message];
}
