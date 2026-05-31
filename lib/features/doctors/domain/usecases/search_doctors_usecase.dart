import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class SearchDoctorsUseCase implements UseCase<List<DoctorEntity>, String> {
  final DoctorRepository repository;
  SearchDoctorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(String query) =>
      repository.searchDoctors(query);
}
