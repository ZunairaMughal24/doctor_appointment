import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterAsDoctorUseCase implements UseCase<UserEntity, RegisterAsDoctorParams> {
  final AuthRepository repository;
  RegisterAsDoctorUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterAsDoctorParams params) =>
      repository.registerAsDoctor(
        uid: params.uid,
        name: params.name,
        email: params.email,
        speciality: params.speciality,
        experience: params.experience,
        phoneNumber: params.phoneNumber,
        location: params.location,
        availability: params.availability,
        services: params.services,
        description: params.description,
        weeklySchedule: params.weeklySchedule,
      );
}

class RegisterAsDoctorParams {
  final String uid;
  final String name;
  final String email;
  final String speciality;
  final String experience;
  final String phoneNumber;
  final String location;
  final String availability;
  final String services;
  final String description;
  final WeeklyAvailability? weeklySchedule;

  const RegisterAsDoctorParams({
    required this.uid,
    required this.name,
    required this.email,
    required this.speciality,
    required this.experience,
    required this.phoneNumber,
    required this.location,
    required this.availability,
    required this.services,
    required this.description,
    this.weeklySchedule,
  });
}
