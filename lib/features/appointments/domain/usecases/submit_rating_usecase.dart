import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';

class SubmitRatingParams {
  final String appointmentId;
  final String doctorId;
  final int rating;
  final String comment;

  const SubmitRatingParams({
    required this.appointmentId,
    required this.doctorId,
    required this.rating,
    this.comment = '',
  });
}

class SubmitRatingUseCase {
  final AppointmentRepository repository;
  const SubmitRatingUseCase(this.repository);

  Future<Either<Failure, void>> call(SubmitRatingParams params) =>
      repository.submitRating(
        appointmentId: params.appointmentId,
        doctorId: params.doctorId,
        rating: params.rating,
        comment: params.comment,
      );
}
