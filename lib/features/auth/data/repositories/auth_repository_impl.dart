import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpPatient({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUpPatient(
        name: name,
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
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
  }) async {
    try {
      final user = await remoteDataSource.signUpDoctor(
        name: name,
        email: email,
        password: password,
        speciality: speciality,
        experience: experience,
        phoneNumber: phoneNumber,
        location: location,
        availability: availability,
        services: services,
        description: description,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final user = await remoteDataSource.registerAsDoctor(
        uid: uid,
        name: name,
        email: email,
        speciality: speciality,
        experience: experience,
        phoneNumber: phoneNumber,
        location: location,
        availability: availability,
        services: services,
        description: description,
        weeklySchedule: weeklySchedule,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
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
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        uid: uid,
        name: name,
        email: email,
        speciality: speciality,
        experience: experience,
        phoneNumber: phoneNumber,
        location: location,
        availability: availability,
        services: services,
        description: description,
        weeklySchedule: weeklySchedule,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> switchRole({
    required String uid,
    required UserRole role,
  }) async {
    try {
      await remoteDataSource.switchRole(uid: uid, role: role);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String uid) async {
    try {
      await remoteDataSource.deleteAccount(uid);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> deleteDoctorProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      final user = await remoteDataSource.deleteDoctorProfile(
        uid: uid,
        name: name,
        email: email,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
