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
      backgroundColor: AppColors.cardBg,
      body: Container(
        color: AppColors.cardBg,
        child: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorInitial || state is DoctorLoading) {
              return const HomeSkeleton();
            }

            final doctors =
                state is DoctorsLoaded ? state.doctors : <DoctorEntity>[];

            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                HomeHeader(greeting: vm.greeting(), username: username),
                const SizedBox(height: 8),
                HealthTipCard(tip: vm.tipOfTheDay),
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
                const SizedBox(height: 3),
                RecommendedDoctorsSection(
                  doctors: doctors,
                  onTap: (d) => vm.openDoctor(context, d),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
