import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorByIdUseCase implements UseCase<DoctorEntity, String> {
  final DoctorRepository repository;
  GetDoctorByIdUseCase(this.repository);

  @override
  Future<Either<Failure, DoctorEntity>> call(String id) =>
      repository.getDoctorById(id);
}
