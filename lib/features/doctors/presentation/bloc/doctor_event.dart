import 'package:equatable/equatable.dart';

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllDoctors extends DoctorEvent {
  const LoadAllDoctors();
}

class LoadDoctorById extends DoctorEvent {
  final String id;
  const LoadDoctorById(this.id);
  @override
  List<Object?> get props => [id];
}

class SearchDoctors extends DoctorEvent {
  final String query;
  const SearchDoctors(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadDoctorsBySpeciality extends DoctorEvent {
  final String speciality;
  const LoadDoctorsBySpeciality(this.speciality);
  @override
  List<Object?> get props => [speciality];
}
