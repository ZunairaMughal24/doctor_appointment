import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, void>> bookAppointment(AppointmentEntity appointment);
  Stream<List<AppointmentEntity>> getUserAppointments(String patientId);
  Stream<List<AppointmentEntity>> getDoctorAppointments(String doctorId);
  Future<Either<Failure, void>> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
    required bool actorIsDoctor,
  });

  Future<Either<Failure, void>> submitRating({
    required String appointmentId,
    required String doctorId,
    required int rating,
    required String comment,
  });

  Future<Either<Failure, List<AppointmentEntity>>> getDoctorReviews(
      String doctorId);
}
