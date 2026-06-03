import 'package:go_router/go_router.dart';

import '../../features/appointments/domain/entities/appointment_entity.dart';
import '../../features/appointments/presentation/pages/appointment_detail_page.dart';
import '../../features/appointments/presentation/pages/my_appointments_page.dart';
import '../../features/appointments/presentation/pages/schedule_appointment_page.dart';
import '../../features/auth/presentation/pages/doctor_sign_up_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_as_doctor_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/widgets/main_shell.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/doctors/domain/entities/doctor_entity.dart';
import '../../features/doctors/presentation/pages/all_diseases_page.dart';
import '../../features/doctors/presentation/pages/all_doctors_page.dart';
import '../../features/doctors/presentation/pages/doctor_detail_page.dart';
import '../../features/doctors/presentation/pages/home_page.dart';
import '../../features/doctors/presentation/pages/search_results_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const doctorSignUp = '/doctor-sign-up';
  static const home = '/home';
  static const appointments = '/appointments';
  static const profile = '/profile';
  static const registerAsDoctor = '/register-as-doctor';
  static const allDoctors = '/doctors';
  static const doctorDetail = '/doctor/:id';
  static const allDiseases = '/diseases';
  static const search = '/search';
  static const scheduleAppointment = '/schedule-appointment';
  static const appointmentDetail = '/appointment-detail';
  static const notifications = '/notifications';

  static String doctorDetailPath(String id) => '/doctor/$id';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // ── Auth / Splash (outside shell) ──────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomePage(),
      ),
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
        path: AppRoutes.registerAsDoctor,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RegisterAsDoctorPage(
            uid: extra['uid'] as String? ?? '',
            prefillName: extra['name'] as String? ?? '',
            prefillEmail: extra['email'] as String? ?? '',
          );
        },
      ),

      // ── Main shell (bottom nav) ─────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.appointments,
            builder: (context, state) {
              final isUser = state.uri.queryParameters['isUser'] != 'false';
              return MyAppointmentsPage(isUser: isUser);
            },
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),

      // ── Detail screens (push on top, no shell)
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
          return DoctorDetailPage(docId: id, doctor: doctor);
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
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsPage(),
      ),
    ],
  );
}
