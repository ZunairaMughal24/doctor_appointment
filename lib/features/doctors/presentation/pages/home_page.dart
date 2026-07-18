import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/di/injection_container.dart';
import 'package:medic/core/router/app_router.dart';
import 'package:medic/core/session/current_session.dart';

import 'package:medic/features/appointments/domain/entities/appointment_entity.dart';
import 'package:medic/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:medic/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:medic/features/appointments/presentation/bloc/appointment_state.dart';
import 'package:medic/features/doctors/domain/entities/doctor_entity.dart';
import 'package:medic/features/doctors/presentation/bloc/doctor_bloc.dart';
import 'package:medic/features/doctors/presentation/bloc/doctor_event.dart';
import 'package:medic/features/doctors/presentation/bloc/doctor_state.dart';
import 'package:medic/features/doctors/presentation/viewmodels/home_view_model.dart';
import 'package:medic/features/doctors/presentation/widgets/doctor_home_sections.dart';
import 'package:medic/features/doctors/presentation/widgets/health_tip_card.dart';
import 'package:medic/features/doctors/presentation/widgets/home_sections.dart';
import 'package:medic/features/doctors/presentation/widgets/home_skeleton.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const _HomeView();
}

// ── Role dispatcher ───────────────────────────────────────────────────────────

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final isDoctor = context.watch<CurrentSession>().isDoctor;
    return isDoctor ? const _DoctorHomeView() : const _PatientHomeView();
  }
}

// ── Patient: browse doctors ───────────────────────────────────────────────────

class _PatientHomeView extends StatelessWidget {
  const _PatientHomeView();

  @override
  Widget build(BuildContext context) {
    const vm = HomeViewModel();
    final username = context.watch<CurrentSession>().name;

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
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<DoctorBloc>().add(const LoadAllDoctors()),
              child: ListView(
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
                    onTap: (d) =>
                        context.push(AppRoutes.doctorDetailPath(d.id), extra: d),
                  ),
                  const CategoriesSection(),
                  AvailableDoctorsSection(
                    doctors: doctors,
                    onTap: (d) =>
                        context.push(AppRoutes.doctorDetailPath(d.id), extra: d),
                  ),
                  const SizedBox(height: 4),
                  const HomeSectionTitle(
                    title: 'Wellness Insight',
                    subtitle: 'Daily health tips for a better lifestyle',
                  ),
                  HealthTipCard(tip: vm.tipOfTheDay),
                  const SizedBox(height: 8),
                  RecommendedDoctorsSection(
                    doctors: doctors,
                    onTap: (d) =>
                        context.push(AppRoutes.doctorDetailPath(d.id), extra: d),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Doctor: appointment dashboard ─────────────────────────────────────────────

class _DoctorHomeView extends StatefulWidget {
  const _DoctorHomeView();

  @override
  State<_DoctorHomeView> createState() => _DoctorHomeViewState();
}

class _DoctorHomeViewState extends State<_DoctorHomeView> {
  late final AppointmentBloc _bloc;

  String get _uid => context.read<CurrentSession>().uid;

  @override
  void initState() {
    super.initState();
    _bloc = sl<AppointmentBloc>()..add(LoadDoctorAppointments(_uid));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<CurrentSession>();

    final doctorState = context.watch<DoctorBloc>().state;
    final myDoctor = doctorState is DoctorsLoaded
        ? doctorState.doctors
            .cast<DoctorEntity?>()
            .firstWhere((d) => d?.id == session.uid, orElse: () => null)
        : null;

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          final appointments = state is AppointmentsLoaded
              ? state.appointments
              : <AppointmentEntity>[];
          final pending = appointments
              .where((a) => a.effectiveStatus == AppointmentStatus.pending)
              .toList();
          final upcoming = appointments
              .where((a) => a.effectiveStatus == AppointmentStatus.confirmed)
              .toList();

          return Scaffold(
            backgroundColor: AppColors.background,
            body: RefreshIndicator(
              onRefresh: () async => _bloc.add(LoadDoctorAppointments(_uid)),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  DoctorHomeHeader(name: session.name),
                  const SizedBox(height: 4),
                  DoctorStatsStrip(
                    pending: pending.length,
                    upcoming: upcoming.length,
                    rating: myDoctor?.rating ?? 0.0,
                  ),
                  const SizedBox(height: 16),
                  DoctorDashboardSection(
                    title: 'Pending Requests',
                    count: pending.length,
                    emptyMessage: 'No pending requests',
                    emptyIcon: Icons.inbox_rounded,
                    appointments: pending.take(3).toList(),
                  ),
                  const SizedBox(height: 8),
                  DoctorDashboardSection(
                    title: 'Upcoming Appointments',
                    count: upcoming.length,
                    emptyMessage: 'No upcoming appointments',
                    emptyIcon: Icons.event_available_rounded,
                    appointments: upcoming.take(3).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
