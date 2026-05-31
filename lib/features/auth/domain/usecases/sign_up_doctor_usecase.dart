import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpDoctorUseCase implements UseCase<UserEntity, SignUpDoctorParams> {
  final AuthRepository repository;
  SignUpDoctorUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpDoctorParams params) =>
      repository.signUpDoctor(
        name: params.name,
        email: params.email,
        password: params.password,
        speciality: params.speciality,
        experience: params.experience,
        phoneNumber: params.phoneNumber,
        location: params.location,
        availability: params.availability,
        services: params.services,
      );
}

class SignUpDoctorParams {
  final String name;
  final String email;
  final String password;
  final String speciality;
  final String experience;
  final String phoneNumber;
  final String location;
  final String availability;
  final String services;

  const SignUpDoctorParams({
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
}
