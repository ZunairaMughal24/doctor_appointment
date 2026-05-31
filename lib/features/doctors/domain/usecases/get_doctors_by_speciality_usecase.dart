import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorsBySpecialityUseCase
    implements UseCase<List<DoctorEntity>, String> {
  final DoctorRepository repository;
  GetDoctorsBySpecialityUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(String speciality) =>
      repository.getDoctorsBySpeciality(speciality);
}
