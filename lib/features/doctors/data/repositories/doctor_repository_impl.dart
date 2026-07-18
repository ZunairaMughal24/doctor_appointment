import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_data_source.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  const DoctorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DoctorEntity>>> getAllDoctors() async {
    try {
      // Data source falls back to bundled seeds on any error, but we still
      // guard here so a future change to that behavior can't leak a raw
      // exception past this layer.
      final doctors = await remoteDataSource.getAllDoctors();
      return Right(doctors);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorEntity>> getDoctorById(String id) async {
    try {
      final doctor = await remoteDataSource.getDoctorById(id);
      return Right(doctor);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DoctorEntity>>> searchDoctors(
      String query) async {
    try {
      final doctors = await remoteDataSource.searchDoctors(query);
      return Right(doctors);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsBySpeciality(
      String speciality) async {
    try {
      final doctors =
          await remoteDataSource.getDoctorsBySpeciality(speciality);
      return Right(doctors);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateDoctorDescription({
    required String doctorId,
    required String description,
  }) async {
    try {
      await remoteDataSource.updateDoctorDescription(
        doctorId: doctorId,
        description: description,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
