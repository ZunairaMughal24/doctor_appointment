import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetAllDoctorsUseCase implements UseCase<List<DoctorEntity>, NoParams> {
  final DoctorRepository repository;
  GetAllDoctorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(NoParams params) =>
      repository.getAllDoctors();
}
