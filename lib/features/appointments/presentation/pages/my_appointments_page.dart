import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/features/auth/domain/entities/user_entity.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_state.dart';
import 'package:fyp/features/appointments/presentation/widgets/appointment_tile.dart';

class MyAppointmentsPage extends StatelessWidget {
  final bool isUser;
  const MyAppointmentsPage({super.key, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isDoctor = authState is AuthAuthenticated &&
        authState.user.role == UserRole.doctor;

    if (isDoctor) {
      return const _DoctorAppointmentsTabs();
    }
    return const _PatientAppointments();
  }
}

// Patient: simple list of their bookings

class _PatientAppointments extends StatefulWidget {
  const _PatientAppointments();

  @override
  State<_PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<_PatientAppointments> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';
    context.read<AppointmentBloc>().add(LoadUserAppointments(uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        title: const Text(
          'My Appointments',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AppointmentsLoaded) {
            if (state.appointments.isEmpty) {
              return AppointmentEmptyState(
                  message: 'No appointments yet',
                  icon: Icons.calendar_today_outlined);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final appt = state.appointments[index];
                return AppointmentTile(
                  title: appt.doctorName,
                  subtitle: appt.appointmentDay,
                  onTap: () =>
                      context.push(AppRoutes.appointmentDetail, extra: appt),
                );
              },
            );
          }
          return AppointmentEmptyState(
              message: 'Could not load appointments',
              icon: Icons.error_outline);
        },
      ),
    );
  }
}

//  Doctor: two tabs (My Patients + My Visits)

class _DoctorAppointmentsTabs extends StatefulWidget {
  const _DoctorAppointmentsTabs();

  @override
  State<_DoctorAppointmentsTabs> createState() =>
      _DoctorAppointmentsTabsState();
}

class _DoctorAppointmentsTabsState extends State<_DoctorAppointmentsTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final authState = context.read<AuthBloc>().state;
    final uid = authState is AuthAuthenticated ? authState.user.uid : '';
    context.read<AppointmentBloc>().add(LoadDoctorAppointments(uid));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        title: const Text(
          'Appointments',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.tabUnselected,
          tabs: const [
            Tab(text: 'My Patients'),
            Tab(text: 'My Visits'),
          ],
          onTap: (index) {
            final authState = context.read<AuthBloc>().state;
            final uid = authState is AuthAuthenticated ? authState.user.uid : '';
            if (index == 0) {
              context.read<AppointmentBloc>().add(LoadDoctorAppointments(uid));
            } else {
              context.read<AppointmentBloc>().add(LoadUserAppointments(uid));
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1 â€” patients who booked with this doctor
          BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AppointmentsLoaded) {
                if (state.appointments.isEmpty) {
                  return AppointmentEmptyState(
                      message: 'No patients yet', icon: Icons.people_outline);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final appt = state.appointments[index];
                    return AppointmentTile(
                      title: appt.patientName,
                      subtitle: appt.appointmentDay,
                      isPatient: true,
                      onTap: () => context.push(AppRoutes.appointmentDetail,
                          extra: appt),
                    );
                  },
                );
              }
              return AppointmentEmptyState(
                  message: 'Could not load', icon: Icons.error_outline);
            },
          ),

          // Tab 2 - this doctor's own visits as a patient
          BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AppointmentsLoaded) {
                if (state.appointments.isEmpty) {
                  return AppointmentEmptyState(
                      message: 'No personal visits yet',
                      icon: Icons.calendar_today_outlined);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final appt = state.appointments[index];
                    return AppointmentTile(
                      title: appt.doctorName,
                      subtitle: appt.appointmentDay,
                      onTap: () => context.push(AppRoutes.appointmentDetail,
                          extra: appt),
                    );
                  },
                );
              }
              return AppointmentEmptyState(
                  message: 'Could not load', icon: Icons.error_outline);
            },
          ),
        ],
      ),
    );
  }
}
