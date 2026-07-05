import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../viewmodels/all_doctors_view_model.dart';
import '../widgets/doctor_list_tile.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class AllDoctorsPage extends StatefulWidget {
  final String? speciality;
  const AllDoctorsPage({super.key, this.speciality});

  @override
  State<AllDoctorsPage> createState() => _AllDoctorsPageState();
}

class _AllDoctorsPageState extends State<AllDoctorsPage> {
  static const _vm = AllDoctorsViewModel();

  /// Whether the search bar is currently shown in the body.
  bool _searchVisible = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final bloc = context.read<DoctorBloc>();
    if (bloc.state is DoctorInitial) bloc.add(const LoadAllDoctors());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searchVisible = true);
    // Request focus after the frame so the TextField is in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _focusNode.unfocus();
    setState(() {
      _searchVisible = false;
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,

      // ── AppBar: title + search icon only ─────────────────────────────────
      appBar: CustomAppBar(
        title: widget.speciality ?? 'All Specialists',
        forceShowBack: true,
        onBackPressed: () => context.go(AppRoutes.home),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            tooltip: 'Search',
            onPressed: _openSearch,
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // ── Search bar — shown in body, above the list ──────────────────
          if (_searchVisible)
            Container(
              color: AppColors.cardBg,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.speciality != null
                        ? 'Search in ${widget.speciality}...'
                        : 'Search doctors, specialties...',
                    hintStyle: TextStyle(
                      color: AppColors.textHint.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 4),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      tooltip: 'Close search',
                      onPressed: _closeSearch,
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),

          // ── Doctor list ─────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<DoctorBloc, DoctorState>(
              builder: (context, state) {
                if (state is DoctorInitial || state is DoctorLoading) {
                  return const AppLoader();
                }

                if (state is DoctorsLoaded) {
                  // Business logic filtering is offloaded to the ViewModel for Clean Architecture compliance.
                  final doctors = _vm.filter(
                    doctors: state.doctors,
                    speciality: widget.speciality,
                    query: _query,
                  );

                  if (doctors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _query.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.person_search_rounded,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _query.isNotEmpty
                                ? 'No results for "$_query"'
                                : 'No doctors found',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context
                        .read<DoctorBloc>()
                        .add(const LoadAllDoctors()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(14.0),
                      physics: const BouncingScrollPhysics(),
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
                        return DoctorListTile(
                          doctor: doctor,
                          tileColor: AppColors.doctorTileColors[
                              index % AppColors.doctorTileColors.length],
                          image: AppAssets.doctorAvatars[
                              index % AppAssets.doctorAvatars.length],
                          onTap: () => _vm.openDoctor(context, doctor),
                        );
                      },
                    ),
                  );
                }

                return const Center(child: Text('Error loading doctors'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
