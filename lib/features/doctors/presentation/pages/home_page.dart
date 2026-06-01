import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';
import 'package:fyp/features/doctors/domain/entities/doctor_entity.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_bloc.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_event.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_state.dart';
import 'package:fyp/core/di/injection_container.dart';
import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/features/doctors/presentation/widgets/home_sections.dart';

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

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _openDetail(BuildContext context, DoctorEntity doctor) =>
      context.push(AppRoutes.doctorDetailPath(doctor.id), extra: doctor);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final username =
        authState is AuthAuthenticated ? authState.user.name : '';

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 233, 242, 250),
        child: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorInitial || state is DoctorLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final doctors =
                state is DoctorsLoaded ? state.doctors : <DoctorEntity>[];

            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                HomeHeader(username: username),
                const SizedBox(height: 35),
                FeaturedDoctorsSection(
                  doctors: doctors,
                  onTap: (d) => _openDetail(context, d),
                ),
                const SizedBox(height: 5),
                const CategoriesSection(),
                AvailableDoctorsSection(
                  doctors: doctors,
                  onTap: (d) => _openDetail(context, d),
                ),
                const SizedBox(height: 3),
                RecommendedDoctorsSection(
                  doctors: doctors,
                  onTap: (d) => _openDetail(context, d),
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

