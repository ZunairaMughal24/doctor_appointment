import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:medic/core/config/firebase_config.dart';
import 'package:medic/core/config/supabase_config.dart';
import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/di/injection_container.dart' as di;
import 'package:medic/core/router/app_router.dart';
import 'package:medic/core/session/current_session.dart';
import 'package:medic/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:medic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medic/features/auth/presentation/bloc/auth_state.dart';
import 'package:medic/features/auth/presentation/session/auth_current_session.dart';
import 'package:medic/features/doctors/presentation/bloc/doctor_bloc.dart';
import 'package:medic/features/doctors/presentation/bloc/doctor_event.dart';
import 'package:medic/features/notifications/presentation/bloc/notification_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load .env — falling back to unconfigured '
        'Firebase/Supabase (features requiring them will be disabled): $e');
  }

  await Firebase.initializeApp(
      options: FirebaseOptions(
          appId: FirebaseConfig.appId,
          apiKey: FirebaseConfig.apiKey,
          messagingSenderId: FirebaseConfig.messagingSenderId,
          projectId: FirebaseConfig.projectId));

  // Initialize Supabase (used only for profile-photo storage).
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // Accepts either the legacy "anon public" key or a new publishable key.
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  // Initalize Dependency Injectioni
  await di.initDependencies();

  // Make the status bar transparent with white icons so it blends
  // naturally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        // Reactive "who's signed in" for every feature except auth itself —
        // depends on AuthBloc above, so must stay after it in this list.
        ChangeNotifierProvider<CurrentSession>(
          create: (context) => AuthCurrentSession(context.read<AuthBloc>()),
        ),
        // Load doctors once at app start — HomePage reads this without re-fetching.
        BlocProvider(
            create: (context) =>
                di.sl<DoctorBloc>()..add(const LoadAllDoctors())),
        BlocProvider(create: (context) => di.sl<AppointmentBloc>()),
        BlocProvider(create: (context) => di.sl<NotificationBloc>()),
      ],
      // Refreshes the global doctor list on every auth transition (sign-in,
      // profile update, role switch, doctor-profile deletion, etc.) so no
      // individual feature needs to reach into DoctorBloc itself to do this.
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<DoctorBloc>().add(const LoadAllDoctors());
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "Medic",
          theme: ThemeData(
            textTheme: GoogleFonts.nunitoTextTheme(),
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: AppColors.primary,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
            ),
          ),
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
