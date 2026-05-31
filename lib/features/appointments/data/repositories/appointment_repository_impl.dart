import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  const AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> bookAppointment(
      AppointmentEntity appointment) async {
    try {
      final model = AppointmentModel(
        id: appointment.id,
        patientId: appointment.patientId,
        patientName: appointment.patientName,
        patientPhone: appointment.patientPhone,
        doctorId: appointment.doctorId,
        doctorName: appointment.doctorName,
        appointmentDay: appointment.appointmentDay,
        appointmentDate: appointment.appointmentDate,
      );
      await remoteDataSource.bookAppointment(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getUserAppointments(
      String patientId) async {
    try {
      final appointments =
          await remoteDataSource.getUserAppointments(patientId);
      return Right(appointments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getDoctorAppointments(
      String doctorId) async {
    try {
      final appointments =
          await remoteDataSource.getDoctorAppointments(doctorId);
      return Right(appointments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
