import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_entity.dart';

/// Logic for the All Doctors list, keeping the page pure UI. Filtering is done
/// in-memory against the already-loaded list so repeat visits never refetch.
class AllDoctorsViewModel {
  const AllDoctorsViewModel();

  /// Returns [doctors] optionally narrowed to a [speciality] (case-insensitive).
  List<DoctorEntity> filter(List<DoctorEntity> doctors, String? speciality) {
    if (speciality == null || speciality.trim().isEmpty) return doctors;
    final s = speciality.toLowerCase();
    return doctors.where((d) => d.speciality.toLowerCase() == s).toList();
  }

  void openDoctor(BuildContext context, DoctorEntity doctor) =>
      context.push(AppRoutes.doctorDetailPath(doctor.id), extra: doctor);
}
