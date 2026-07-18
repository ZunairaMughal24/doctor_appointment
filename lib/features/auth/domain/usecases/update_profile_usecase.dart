import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) =>
      repository.updateProfile(
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

class UpdateProfileParams {
  final String uid;
  final String name;
  final String email;

  // Optional professional fields, persisted only when a doctor profile exists.
  final String? speciality;
  final String? experience;
  final String? phoneNumber;
  final String? location;
  final String? availability;
  final String? services;
  final String? description;
  final WeeklyAvailability? weeklySchedule;

  const UpdateProfileParams({
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
    this.weeklySchedule,
  });
}
