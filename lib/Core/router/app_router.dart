import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/domain/entities/appointment_entity.dart';
import '../../features/appointments/presentation/pages/appointment_detail_page.dart';
import '../../features/appointments/presentation/pages/my_appointments_page.dart';
import '../../features/appointments/presentation/pages/schedule_appointment_page.dart';
import '../../features/auth/presentation/pages/doctor_sign_up_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/doctors/domain/entities/doctor_entity.dart';
import '../../features/doctors/presentation/pages/all_diseases_page.dart';
import '../../features/doctors/presentation/pages/all_doctors_page.dart';
import '../../features/doctors/presentation/pages/doctor_detail_page.dart';
import '../../features/doctors/presentation/pages/home_page.dart';
import '../../features/doctors/presentation/pages/search_results_page.dart';

class AppRoutes {
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const doctorSignUp = '/doctor-sign-up';
  static const home = '/home';
  static const allDoctors = '/doctors';
  static const doctorDetail = '/doctor/:id';
  static const allDiseases = '/diseases';
  static const search = '/search';
  static const myAppointments = '/appointments';
  static const scheduleAppointment = '/schedule-appointment';
  static const appointmentDetail = '/appointment-detail';

  static String doctorDetailPath(String id) => '/doctor/$id';
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

FirebaseAuth get _auth => FirebaseAuth.instance;

final appRouter = GoRouter(
  initialLocation: AppRoutes.signIn,
  refreshListenable: _GoRouterRefreshStream(
    _auth.authStateChanges(),
  ),
  redirect: (context, state) {
    final isLoggedIn = _auth.currentUser != null;
    final isOnAuthRoute = state.matchedLocation == AppRoutes.signIn ||
        state.matchedLocation == AppRoutes.signUp ||
        state.matchedLocation == AppRoutes.doctorSignUp;

    if (!isLoggedIn && !isOnAuthRoute) return AppRoutes.signIn;
    if (isLoggedIn && isOnAuthRoute) return AppRoutes.home;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.signIn,
      builder: (_, __) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (_, __) => const SignUpPage(),
    ),
    GoRoute(
      path: AppRoutes.doctorSignUp,
      builder: (_, __) => const DoctorSignUpPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.allDoctors,
      builder: (context, state) {
        final speciality = state.uri.queryParameters['speciality'];
        return AllDoctorsPage(speciality: speciality);
      },
    ),
    GoRoute(
      path: AppRoutes.doctorDetail,
      builder: (context, state) {
        final doctor = state.extra as DoctorEntity?;
        final id = state.pathParameters['id']!;
        return DoctorDetailPage(doctorId: id, doctor: doctor);
      },
    ),
    GoRoute(
      path: AppRoutes.allDiseases,
      builder: (_, __) => const AllDiseasesPage(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchResultsPage(initialQuery: query);
      },
    ),
    GoRoute(
      path: AppRoutes.myAppointments,
      builder: (context, state) {
        final isDoctor = state.uri.queryParameters['isDoctor'] == 'true';
        return MyAppointmentsPage(isDoctor: isDoctor);
      },
    ),
    GoRoute(
      path: AppRoutes.scheduleAppointment,
      builder: (context, state) {
        final doctor = state.extra as DoctorEntity;
        return ScheduleAppointmentPage(doctor: doctor);
      },
    ),
    GoRoute(
      path: AppRoutes.appointmentDetail,
      builder: (context, state) {
        final appointment = state.extra as AppointmentEntity;
        return AppointmentDetailPage(appointment: appointment);
      },
    ),
  ],
);
