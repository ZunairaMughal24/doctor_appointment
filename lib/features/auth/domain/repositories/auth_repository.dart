import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpPatient({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpDoctor({
    required String name,
    required String email,
    required String password,
    required String speciality,
    required String experience,
    required String phoneNumber,
    required String location,
    required String availability,
    required String services,
    required String description,
  });

  Future<Either<Failure, UserEntity>> registerAsDoctor({
    required String uid,
    required String name,
    required String email,
    required String speciality,
    required String experience,
    required String phoneNumber,
    required String location,
    required String availability,
    required String services,
    required String description,
    WeeklyAvailability? weeklySchedule,
  });

  Future<Either<Failure, UserEntity>> updateProfile({
    required String uid,
    required String name,
    required String email,
    String? speciality,
    String? experience,
    String? phoneNumber,
    String? location,
    String? availability,
    String? services,
    String? description,
    WeeklyAvailability? weeklySchedule,
  });

  Future<Either<Failure, void>> switchRole({
    required String uid,
    required UserRole role,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Deletes all of the user's data and their auth account.
  Future<Either<Failure, void>> deleteAccount(String uid);

  /// Removes the doctor profile and converts the account to a patient.
  Future<Either<Failure, UserEntity>> deleteDoctorProfile({
    required String uid,
    required String name,
    required String email,
  });
}
