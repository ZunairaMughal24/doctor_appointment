import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_entity.dart';

/// Logic for the All Doctors list, keeping the page pure UI. Filtering is done
/// in-memory against the already-loaded list so repeat visits never refetch.
class AllDoctorsViewModel {
  const AllDoctorsViewModel();

  /// Returns [doctors] narrowed to a [speciality] (optionally) and further filtered
  /// by a search [query] (matching name or speciality).
  List<DoctorEntity> filter({
    required List<DoctorEntity> doctors,
    String? speciality,
    String query = '',
  }) {
    // 1. First filter by speciality if provided
    var list = doctors;
    if (speciality != null && speciality.trim().isNotEmpty) {
      final s = speciality.toLowerCase();
      list = list.where((d) => d.speciality.toLowerCase() == s).toList();
    }

    // 2. Then filter by query if provided
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.speciality.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  void openDoctor(BuildContext context, DoctorEntity doctor) =>
      context.push(AppRoutes.doctorDetailPath(doctor.id), extra: doctor);
}
