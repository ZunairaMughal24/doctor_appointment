import 'package:flutter/material.dart';

import '../../domain/entities/doctor_entity.dart';

/// Logic and search-bar state for the All Doctors list, keeping the page pure
/// UI. Filtering is done in-memory against the already-loaded list so repeat
/// visits never refetch.
class AllDoctorsViewModel {
  AllDoctorsViewModel({required this.onChange});
  final VoidCallback onChange;

  final searchController = TextEditingController();
  final focusNode = FocusNode();

  bool searchVisible = false;
  String query = '';

  bool _disposed = false;

  void _set(VoidCallback fn) {
    fn();
    onChange();
  }

  void openSearch() {
    _set(() => searchVisible = true);
    // Request focus after the frame so the TextField is in the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) focusNode.requestFocus();
    });
  }

  void closeSearch() {
    focusNode.unfocus();
    _set(() {
      searchVisible = false;
      query = '';
      searchController.clear();
    });
  }

  void updateQuery(String value) => _set(() => query = value);

  /// Returns [doctors] narrowed to a [speciality] (optionally) and further
  /// filtered by the current search query (matching name or speciality).
  List<DoctorEntity> filter({
    required List<DoctorEntity> doctors,
    String? speciality,
  }) {
    var list = doctors;
    if (speciality != null && speciality.trim().isNotEmpty) {
      final s = speciality.toLowerCase();
      list = list.where((d) => d.speciality.toLowerCase() == s).toList();
    }

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

  void dispose() {
    _disposed = true;
    searchController.dispose();
    focusNode.dispose();
  }
}
