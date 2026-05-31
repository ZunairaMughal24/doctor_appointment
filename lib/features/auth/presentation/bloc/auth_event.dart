import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpPatientRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthSignUpPatientRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignUpDoctorRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String speciality;
  final String experience;
  final String phoneNumber;
  final String location;
  final String availability;
  final String services;

  const AuthSignUpDoctorRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.speciality,
    required this.experience,
    required this.phoneNumber,
    required this.location,
    required this.availability,
    required this.services,
  });
  @override
  List<Object?> get props =>
      [name, email, speciality, experience, phoneNumber, location];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
