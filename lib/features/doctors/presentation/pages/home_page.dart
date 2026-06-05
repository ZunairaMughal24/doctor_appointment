import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/core/constants/app_colors.dart';

import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';
import 'package:fyp/features/doctors/domain/entities/doctor_entity.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_bloc.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_state.dart';
import 'package:fyp/features/doctors/presentation/viewmodels/home_view_model.dart';
import 'package:fyp/features/doctors/presentation/widgets/health_tip_card.dart';
import 'package:fyp/features/doctors/presentation/widgets/home_sections.dart';
import 'package:fyp/features/doctors/presentation/widgets/home_skeleton.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const _HomeView();
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    const vm = HomeViewModel();
    final authState = context.watch<AuthBloc>().state;
    final username = authState is AuthAuthenticated ? authState.user.name : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,
        child: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorInitial || state is DoctorLoading) {
              return const HomeSkeleton();
            }

            final doctors =
                state is DoctorsLoaded ? state.doctors : <DoctorEntity>[];

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                HomeHeader(greeting: vm.greeting(), username: username),
                const HomeSectionTitle(
                  title: 'Overview',
                  subtitle: 'Quick numbers on our medical network',
                ),
                const HomeStatsStrip(),
                const SizedBox(height: 8),
                FeaturedDoctorsSection(
                  doctors: doctors,
                  onTap: (d) => vm.openDoctor(context, d),
                ),
                const SizedBox(height: 5),
                const CategoriesSection(),
                AvailableDoctorsSection(
                  doctors: doctors,
                  onTap: (d) => vm.openDoctor(context, d),
                ),
                const SizedBox(height: 12),
                const HomeSectionTitle(
                  title: 'Wellness Insight',
                  subtitle: 'Daily health tips for a better lifestyle',
                ),
                HealthTipCard(tip: vm.tipOfTheDay),
                const SizedBox(height: 8),
                RecommendedDoctorsSection(
                  doctors: doctors,
                  onTap: (d) => vm.openDoctor(context, d),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
