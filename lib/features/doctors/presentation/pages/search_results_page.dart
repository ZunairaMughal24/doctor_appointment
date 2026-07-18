import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../viewmodels/search_results_viewmodel.dart';
import '../widgets/doctor_card.dart';
import '../../../../core/widgets/custom_app_bar.dart';

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
      appBar: CustomAppBar(
        onBackPressed: () => context.pop(),
        titleWidget: TextField(
          controller: _vm.controller,
          autofocus: true,
          style: AppTextStyles.body.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search doctors, specialties...',
            hintStyle: AppTextStyles.body.copyWith(color: Colors.white70),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (query) => _vm.onQueryChanged(context, query),
        ),
      ),
      body: Column(
        children: [
          // ── Specialty filter chips ───────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _SpecialtyChip(
                  label: 'All',
                  selected: _vm.selectedSpecialty == null,
                  onTap: () => setState(() =>
                      _vm.onSpecialtySelected(context, null)),
                ),
                for (final s in SearchResultsViewModel.specialties)
                  _SpecialtyChip(
                    label: s,
                    selected: _vm.selectedSpecialty == s,
                    onTap: () => setState(() =>
                        _vm.onSpecialtySelected(context, s)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Results ─────────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<DoctorBloc, DoctorState>(
              builder: (context, state) {
                if (state is DoctorLoading) return const AppLoader();
                if (state is DoctorsLoaded) {
                  if (state.doctors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 64, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text('No results found',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _vm.refresh(context),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
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
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SpecialtyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: AppTextStyles.label.copyWith(
          color: selected ? Colors.white : AppColors.primary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.inputBorder,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
