import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';

/// Owns the search field controller and translates query changes into
/// [DoctorBloc] events, keeping the search screen pure UI.
class SearchResultsViewModel {
  final TextEditingController controller;

  SearchResultsViewModel(String initialQuery)
      : controller = TextEditingController(text: initialQuery);

  void onQueryChanged(BuildContext context, String query) {
    final bloc = context.read<DoctorBloc>();
    if (query.isEmpty) {
      bloc.add(const LoadAllDoctors());
    } else {
      bloc.add(SearchDoctors(query));
    }
  }

  void dispose() => controller.dispose();
}
