import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

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

class AuthRegisterAsDoctorRequested extends AuthEvent {
  final String uid;
  final String name;
  final String email;
  final String speciality;
  final String experience;
  final String phoneNumber;
  final String location;
  final String availability;
  final String services;

  const AuthRegisterAsDoctorRequested({
    required this.uid,
    required this.name,
    required this.email,
    required this.speciality,
    required this.experience,
    required this.phoneNumber,
    required this.location,
    required this.availability,
    required this.services,
  });
  @override
  List<Object?> get props => [uid, speciality];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String uid;
  final String name;
  final String email;

  /// Extra professional fields — only sent (and persisted) for doctor users.
  final String? speciality;
  final String? experience;
  final String? phoneNumber;
  final String? location;
  final String? availability;
  final String? services;
  final String? description;

  const AuthUpdateProfileRequested({
    required this.uid,
    required this.name,
    required this.email,
    this.speciality,
    this.experience,
    this.phoneNumber,
    this.location,
    this.availability,
    this.services,
    this.description,
  });
  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        speciality,
        experience,
        phoneNumber,
        location,
        availability,
        services,
        description,
      ];
}

class AuthSwitchRoleRequested extends AuthEvent {
  final UserRole role;
  const AuthSwitchRoleRequested(this.role);
  @override
  List<Object?> get props => [role];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
