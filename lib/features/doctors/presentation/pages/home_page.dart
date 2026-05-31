import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/disease_entity.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../widgets/disease_card.dart';
import '../widgets/doctor_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorBloc>()..add(const LoadAllDoctors()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSpecialtiesSection(context),
                const SizedBox(height: 28),
                _buildDoctorsSection(context),
                const SizedBox(height: 28),
                _buildDiseasesSection(context),
                const SizedBox(height: 28),
                _buildAllDoctorsSection(context),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          bottom: 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Find your Doctor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.myAppointments),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month_outlined,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push(AppRoutes.search),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Search doctors, specialties...',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSection(BuildContext context) {
    final specialties = [
      ('Cardiologist', Icons.favorite_outline),
      ('Dentist', Icons.mood_outlined),
      ('Neurologist', Icons.psychology_outlined),
      ('Orthopedist', Icons.accessibility_outlined),
      ('Dermatologist', Icons.face_outlined),
      ('Ophthalmologist', Icons.visibility_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Specialties',
          actionLabel: 'See All',
          onAction: () => context.push(AppRoutes.allDiseases),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: specialties
                .map((s) => _SpecialtyChip(
                      label: s.$1,
                      icon: s.$2,
                      onTap: () => context.push(
                          '${AppRoutes.allDoctors}?speciality=${s.$1}'),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Top Doctors',
          actionLabel: 'See All',
          onAction: () => context.push(AppRoutes.allDoctors),
        ),
        const SizedBox(height: 14),
        BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorLoading) {
              return const SizedBox(
                  height: 180, child: AppLoader());
            }
            if (state is DoctorsLoaded && state.doctors.isNotEmpty) {
              final featured = state.doctors.take(4).toList();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: featured
                      .map((doc) => DoctorCard(
                            doctor: doc,
                            compact: true,
                            onTap: () => context.push(
                              AppRoutes.doctorDetailPath(doc.id),
                              extra: doc,
                            ),
                          ))
                      .toList(),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildDiseasesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Browse by Disease',
          actionLabel: 'See All',
          onAction: () => context.push(AppRoutes.allDiseases),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: Diseases.all
                .map((d) => DiseaseCard(
                      disease: d,
                      onTap: () => context.push(
                          '${AppRoutes.allDoctors}?speciality=${d.speciality}'),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAllDoctorsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Available Doctors',
          actionLabel: 'See All',
          onAction: () => context.push(AppRoutes.allDoctors),
        ),
        const SizedBox(height: 14),
        BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorsLoaded) {
              return Column(
                children: state.doctors
                    .take(5)
                    .map((doc) => DoctorCard(
                          doctor: doc,
                          onTap: () => context.push(
                            AppRoutes.doctorDetailPath(doc.id),
                            extra: doc,
                          ),
                        ))
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SpecialtyChip(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.label
                    .copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
