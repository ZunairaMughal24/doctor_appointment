import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
import '../widgets/appointment_card.dart';

class MyAppointmentsPage extends StatelessWidget {
  final bool isDoctor;
  const MyAppointmentsPage({super.key, this.isDoctor = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = sl<AppointmentBloc>();
            final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
            if (isDoctor) {
              bloc.add(LoadDoctorAppointments(uid));
            } else {
              bloc.add(LoadUserAppointments(uid));
            }
            return bloc;
          },
        ),
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: _MyAppointmentsView(isDoctor: isDoctor),
    );
  }
}

class _MyAppointmentsView extends StatelessWidget {
  final bool isDoctor;
  const _MyAppointmentsView({required this.isDoctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isDoctor ? 'Patient Appointments' : 'My Appointments'),
        leading: isDoctor
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => context.pop(),
              ),
        actions: isDoctor
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context
                          .read<AuthBloc>()
                          .add(const AuthSignOutRequested());
                      context.go(AppRoutes.signIn);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: AppColors.error,
                              size: 18),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentLoading) return const AppLoader();

          if (state is AppointmentError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.error)),
            );
          }

          if (state is AppointmentsLoaded) {
            if (state.appointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 64, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text(
                      'No appointments yet',
                      style: AppTextStyles.h4
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Book your first appointment',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                    if (!isDoctor) ...[
                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.search),
                        label: const Text('Find a Doctor'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: state.appointments.length,
              itemBuilder: (context, index) {
                final appt = state.appointments[index];
                return AppointmentCard(
                  appointment: appt,
                  isDoctor: isDoctor,
                  onTap: () => context.push(
                    AppRoutes.appointmentDetail,
                    extra: appt,
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
