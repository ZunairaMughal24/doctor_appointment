import 'package:equatable/equatable.dart';

enum UserRole { patient, doctor }

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isDoctor => role == UserRole.doctor;

  @override
  List<Object?> get props => [uid, name, email, role];
}
