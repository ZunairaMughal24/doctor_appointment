import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/di/injection_container.dart';
import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/features/auth/domain/entities/user_entity.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';
import 'package:fyp/features/appointments/domain/entities/appointment_entity.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_state.dart';
import 'package:fyp/features/appointments/presentation/widgets/appointment_list_skeleton.dart';
import 'package:fyp/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:fyp/features/appointments/presentation/viewmodels/appointment_auto_complete.dart';
import 'package:fyp/features/appointments/presentation/viewmodels/appointment_reminders.dart';

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

// ── Patient: simple list of their bookings ───────────────────────────────────

class _PatientAppointments extends StatefulWidget {
  const _PatientAppointments();

  @override
  State<_PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<_PatientAppointments> {
  String get _uid {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.uid : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(LoadUserAppointments(_uid));
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
        builder: (context, state) => _AppointmentListBody(
          state: state,
          titleOf: (a) => a.doctorName,
          currentUserId: _uid,
          emptyMessage: 'No appointments yet',
          emptyIcon: Icons.calendar_today_outlined,
          onRetry: () =>
              context.read<AppointmentBloc>().add(LoadUserAppointments(_uid)),
        ),
      ),
    );
  }
}

// ── Doctor: two tabs, each with its own isolated AppointmentBloc instance ─────

class _DoctorAppointmentsTabs extends StatefulWidget {
  const _DoctorAppointmentsTabs();

  @override
  State<_DoctorAppointmentsTabs> createState() =>
      _DoctorAppointmentsTabsState();
}

class _DoctorAppointmentsTabsState extends State<_DoctorAppointmentsTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AppointmentBloc _patientsBloc;
  late final AppointmentBloc _visitsBloc;

  String get _uid {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.uid : '';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _patientsBloc = sl<AppointmentBloc>()..add(LoadDoctorAppointments(_uid));
    _visitsBloc = sl<AppointmentBloc>()..add(LoadUserAppointments(_uid));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _patientsBloc.close();
    _visitsBloc.close();
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
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1 – patients who booked with this doctor
          BlocProvider.value(
            value: _patientsBloc,
            child: BlocBuilder<AppointmentBloc, AppointmentState>(
              builder: (context, state) => _AppointmentListBody(
                state: state,
                titleOf: (a) => a.patientName,
                isPatient: true,
                currentUserId: _uid,
                emptyMessage: 'No patients yet',
                emptyIcon: Icons.people_outline,
                onRetry: () =>
                    _patientsBloc.add(LoadDoctorAppointments(_uid)),
              ),
            ),
          ),

          // Tab 2 – this doctor's own visits as a patient
          BlocProvider.value(
            value: _visitsBloc,
            child: BlocBuilder<AppointmentBloc, AppointmentState>(
              builder: (context, state) => _AppointmentListBody(
                state: state,
                titleOf: (a) => a.doctorName,
                currentUserId: _uid,
                emptyMessage: 'No personal visits yet',
                emptyIcon: Icons.calendar_today_outlined,
                onRetry: () => _visitsBloc.add(LoadUserAppointments(_uid)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared list body: handles loading (skeleton), empty, loaded, error ────────

class _AppointmentListBody extends StatelessWidget {
  final AppointmentState state;
  final String Function(AppointmentEntity) titleOf;
  final bool isPatient;
  final String currentUserId;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback onRetry;

  const _AppointmentListBody({
    required this.state,
    required this.titleOf,
    required this.currentUserId,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onRetry,
    this.isPatient = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = this.state;

    if (state is AppointmentLoading || state is AppointmentInitial) {
      return const AppointmentListSkeleton();
    }

    if (state is AppointmentError) {
      return _RetryState(message: state.message, onRetry: onRetry);
    }

    if (state is AppointmentsLoaded) {
      if (state.appointments.isEmpty) {
        return AppointmentEmptyState(message: emptyMessage, icon: emptyIcon);
      }
      // Fire idempotent in-app reminders for any of today's appointments, and
      // persist completion for any whose session window has ended.
      AppointmentReminders.fireDayOf(state.appointments, currentUserId, titleOf);
      AppointmentAutoComplete.run(state.appointments);
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.appointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final appt = state.appointments[index];
          return AppointmentTile(
            title: titleOf(appt),
            subtitle: appt.appointmentDay,
            isPatient: isPatient,
            status: appt.effectiveStatus,
            onTap: () async {
              final changed =
                  await context.push(AppRoutes.appointmentDetail, extra: appt);
              if (changed == true) onRetry(); // refresh after confirm/cancel
            },
          );
        },
      );
    }

    return AppointmentEmptyState(message: emptyMessage, icon: emptyIcon);
  }
}

class _RetryState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _RetryState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 15)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
