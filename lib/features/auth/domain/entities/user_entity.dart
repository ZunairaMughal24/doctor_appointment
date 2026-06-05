import 'package:equatable/equatable.dart';

enum UserRole { patient, doctor }

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final bool hasDoctorProfile;

  /// Profile photo URL. For patients this is shown only on the profile screen;
  /// for doctors the doctor record's imageUrl is what syncs across the app.
  final String? imageUrl;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.hasDoctorProfile = false,
    this.imageUrl,
  });

  bool get isDoctor => role == UserRole.doctor;

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    bool? hasDoctorProfile,
    String? imageUrl,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      hasDoctorProfile: hasDoctorProfile ?? this.hasDoctorProfile,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props =>
      [uid, name, email, role, hasDoctorProfile, imageUrl];
}
