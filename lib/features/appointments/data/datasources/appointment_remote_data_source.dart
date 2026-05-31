import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<void> bookAppointment(AppointmentModel appointment);
  Future<List<AppointmentModel>> getUserAppointments(String patientId);
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final FirebaseFirestore firestore;

  const AppointmentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> bookAppointment(AppointmentModel appointment) async {
    try {
      await firestore
          .collection('appointments')
          .add(appointment.toFirestore());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AppointmentModel>> getUserAppointments(String patientId) async {
    try {
      final snapshot = await firestore
          .collection('appointments')
          .where('appointment_by_id', isEqualTo: patientId)
          .get();
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      final snapshot = await firestore
          .collection('appointments')
          .where('appointment_with_id', isEqualTo: doctorId)
          .get();
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
