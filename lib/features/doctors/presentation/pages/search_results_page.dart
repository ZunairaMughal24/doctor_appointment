import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../viewmodels/search_results_viewmodel.dart';
import '../widgets/doctor_card.dart';

class SearchResultsPage extends StatelessWidget {
  final String initialQuery;

  const SearchResultsPage({super.key, this.initialQuery = ''});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<DoctorBloc>();
        if (initialQuery.isNotEmpty) {
          bloc.add(SearchDoctors(initialQuery));
        } else {
          bloc.add(const LoadAllDoctors());
        }
        return bloc;
      },
      child: _SearchView(initialQuery: initialQuery),
    );
  }
}

class _SearchView extends StatefulWidget {
  final String initialQuery;
  const _SearchView({required this.initialQuery});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final SearchResultsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = SearchResultsViewModel(widget.initialQuery);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _vm.controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search doctors, specialties...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (query) => _vm.onQueryChanged(context, query),
        ),
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorLoading) return const AppLoader();
          if (state is DoctorsLoaded) {
            if (state.doctors.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off,
                        size: 64, color: AppColors.textHint),
                    SizedBox(height: 12),
                    Text('No results found',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: state.doctors.length,
              itemBuilder: (_, index) {
                final doc = state.doctors[index];
                return DoctorCard(
                  doctor: doc,
                  onTap: () => context.push(
                    AppRoutes.doctorDetailPath(doc.id),
                    extra: doc,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
