import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetDoctorReviewsUseCase {
  final AppointmentRepository repository;
  const GetDoctorReviewsUseCase(this.repository);

  Future<Either<Failure, List<AppointmentEntity>>> call(String doctorId) =>
      repository.getDoctorReviews(doctorId);
}
