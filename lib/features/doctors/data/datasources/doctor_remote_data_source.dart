import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../constants/doctor_seeds.dart';
import '../models/doctor_model.dart';

abstract class DoctorRemoteDataSource {
  Future<List<DoctorModel>> getAllDoctors();
  Future<DoctorModel> getDoctorById(String id);
  Future<List<DoctorModel>> searchDoctors(String query);
  Future<List<DoctorModel>> getDoctorsBySpeciality(String speciality);
  Future<void> updateDoctorDescription({
    required String doctorId,
    required String description,
  });
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final FirebaseFirestore firestore;

  const DoctorRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final snapshot = await firestore.collection('doctors').get();
      if (snapshot.docs.isEmpty) return kDoctorSeeds;
      return snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (_) {
      // Firestore unavailable (permission/network) — return seeds
      return kDoctorSeeds;
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
      final results = snapshot.docs
          .where((doc) =>
              (doc.data()['name'] ?? '').toLowerCase().contains(lower) ||
              (doc.data()['speciality'] ?? '').toLowerCase().contains(lower))
          .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
          .toList();
      if (results.isEmpty) {
        return kDoctorSeeds
            .where((d) =>
                d.name.toLowerCase().contains(lower) ||
                d.speciality.toLowerCase().contains(lower))
            .toList();
      }
      return results;
    } catch (_) {
      final lower = query.toLowerCase();
      return kDoctorSeeds
          .where((d) =>
              d.name.toLowerCase().contains(lower) ||
              d.speciality.toLowerCase().contains(lower))
          .toList();
    }
  }

  @override
  Future<List<DoctorModel>> getDoctorsBySpeciality(String speciality) async {
    try {
      final snapshot = await firestore
          .collection('doctors')
          .where('speciality', isEqualTo: speciality)
          .get();
      if (snapshot.docs.isEmpty) {
        return kDoctorSeeds
            .where((d) => d.speciality == speciality)
            .toList();
      }
      return snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return kDoctorSeeds.where((d) => d.speciality == speciality).toList();
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
