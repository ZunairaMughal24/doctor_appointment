import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      var snapshot = await firestore.collection('doctors').get();
      final existing = {for (final doc in snapshot.docs) doc.id: doc.data()};

      // Seed (or repair) the default doctors. We (re)write a seed when its
      // document is missing OR when it predates the richer fields added later
      // (services / description / schedule). The previous guard only checked
      // that *some* seed doc existed, so stale seeds kept rendering blank
      // Services/Description on the detail screen.
      final outdated = kDoctorSeeds.where((seed) {
        final data = existing[seed.id];
        if (data == null) return true;
        final noServices = (data['services'] ?? '').toString().isEmpty;
        final noDescription = (data['description'] ?? '').toString().isEmpty;
        final noSchedule = data['schedule'] == null;
        return noServices || noDescription || noSchedule;
      }).toList();

      if (outdated.isNotEmpty) {
        for (final seed in outdated) {
          try {
            await firestore
                .collection('doctors')
                .doc(seed.id)
                .set(seed.toFirestore(), SetOptions(merge: true));
          } catch (_) {
            // Permission/network issue on a single seed — skip and continue.
          }
        }
        // Re-fetch so the returned list includes the repaired/seeded docs.
        snapshot = await firestore.collection('doctors').get();
      }

      if (snapshot.docs.isEmpty) return kDoctorSeeds;

      // Overlay the bundled seed whenever a stored seed still lacks its rich
      // fields (e.g. the repair write above was blocked by security rules), so
      // dummy doctors always render full info instead of blank Description.
      final seedById = {for (final s in kDoctorSeeds) s.id: s};
      final result = snapshot.docs.map((doc) {
        final model = DoctorModel.fromFirestore(doc.data(), doc.id);
        final seed = seedById[doc.id];
        if (seed != null &&
            (model.description.isEmpty || model.services.isEmpty)) {
          return seed; // overlaid bundled seed
        }
        return model;
      }).toList();

      if (kDebugMode) {
        debugPrint('[Doctors] getAllDoctors -> ${result.length} doctor(s):');
        for (final d in result) {
          debugPrint('[Doctors]   ${d.id} "${d.name}" '
              'descLen=${d.description.length} servicesLen=${d.services.length}');
        }
      }
      return result;
    } catch (e) {
      // Firestore unavailable (permission/network) — fall back to in-memory seeds.
      debugPrint('[Doctors] getAllDoctors error: $e — returning in-memory seeds');
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
