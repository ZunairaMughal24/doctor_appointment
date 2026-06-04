import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/di/injection_container.dart' as di;
import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/core/services/push_notification_service.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_bloc.dart';
import 'package:fyp/features/doctors/presentation/bloc/doctor_event.dart';
import 'package:fyp/features/notifications/presentation/bloc/notification_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          appId: '1:201017378885:android:91bb9b88ca8b98e9f47b2c',
          apiKey: 'AIzaSyBaPOGgycLamuvQVXfEc53usmrlIB8Tc3w',
          messagingSenderId: '201017378885',
          projectId: 'final-project-e6c97'));

  // Initialize Dependency Injection
  await di.initDependencies();

  // Initialize Push Notifications
  try {
    await PushNotificationService.initialize();
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        // Load doctors once at app start — HomePage reads this without re-fetching.
        BlocProvider(create: (context) => di.sl<DoctorBloc>()..add(const LoadAllDoctors())),
        BlocProvider(create: (context) => di.sl<AppointmentBloc>()),
        BlocProvider(create: (context) => di.sl<NotificationBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: "Medic",
        theme: ThemeData(
          textTheme: GoogleFonts.nunitoTextTheme(),
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: AppColors.primary,
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}

