import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/doctor_model.dart';

abstract class DoctorRemoteDataSource {
  Future<List<DoctorModel>> getAllDoctors();
  Future<DoctorModel> getDoctorById(String id);
  Future<List<DoctorModel>> searchDoctors(String query);
  Future<List<DoctorModel>> getDoctorsBySpeciality(String speciality);
  Future<void> updateDoctorDescription(
      {required String doctorId, required String description});
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final FirebaseFirestore firestore;

  const DoctorRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final snapshot = await firestore.collection('doctors').get();
      return snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DoctorModel> getDoctorById(String id) async {
    try {
      final doc = await firestore.collection('doctors').doc(id).get();
      if (!doc.exists) throw const NotFoundException('Doctor not found.');
      return DoctorModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<DoctorModel>> searchDoctors(String query) async {
    try {
      final snapshot = await firestore.collection('doctors').get();
      final lower = query.toLowerCase();
      return snapshot.docs
          .where((doc) =>
              (doc.data()['name'] ?? '').toLowerCase().contains(lower) ||
              (doc.data()['speciality'] ?? '').toLowerCase().contains(lower))
          .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<DoctorModel>> getDoctorsBySpeciality(String speciality) async {
    try {
      final snapshot = await firestore
          .collection('doctors')
          .where('speciality', isEqualTo: speciality)
          .get();
      return snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateDoctorDescription({
    required String doctorId,
    required String description,
  }) async {
    try {
      await firestore
          .collection('doctors')
          .doc(doctorId)
          .update({'description': description});
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
