import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';

class SearchResultsViewModel {
  final TextEditingController controller;
  String? selectedSpecialty;

  static const List<String> specialties = [
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Pediatrician',
    'Orthopedist',
    'Gynecologist',
  ];

  SearchResultsViewModel(String initialQuery)
      : controller = TextEditingController(text: initialQuery);

  void onQueryChanged(BuildContext context, String query) {
    selectedSpecialty = null;
    final bloc = context.read<DoctorBloc>();
    if (query.isEmpty) {
      bloc.add(const LoadAllDoctors());
    } else {
      bloc.add(SearchDoctors(query));
    }
  }

  void onSpecialtySelected(BuildContext context, String? specialty) {
    selectedSpecialty = specialty;
    controller.clear();
    final bloc = context.read<DoctorBloc>();
    if (specialty == null) {
      bloc.add(const LoadAllDoctors());
    } else {
      bloc.add(LoadDoctorsBySpeciality(specialty));
    }
  }

  void dispose() => controller.dispose();
}
