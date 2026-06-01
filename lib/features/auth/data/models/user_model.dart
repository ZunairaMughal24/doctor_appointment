import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    super.hasDoctorProfile = false,
  });

  factory UserModel.fromFirestore(
    Map<String, dynamic> data,
    String uid, {
    bool hasDoctorProfile = false,
  }) {
    final isDoctor = data['role'] == 'doctor';
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: isDoctor ? UserRole.doctor : UserRole.patient,
      hasDoctorProfile: hasDoctorProfile || isDoctor,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role == UserRole.doctor ? 'doctor' : 'patient',
      };
}
