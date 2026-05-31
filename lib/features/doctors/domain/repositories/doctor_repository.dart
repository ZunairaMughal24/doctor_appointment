import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor_entity.dart';

abstract class DoctorRepository {
  Future<Either<Failure, List<DoctorEntity>>> getAllDoctors();
  Future<Either<Failure, DoctorEntity>> getDoctorById(String id);
  Future<Either<Failure, List<DoctorEntity>>> searchDoctors(String query);
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsBySpeciality(
      String speciality);
  Future<Either<Failure, void>> updateDoctorDescription({
    required String doctorId,
    required String description,
  });
}
