import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_preferences.dart';

import '../../features/appointments/data/datasources/appointment_remote_data_source.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/book_appointment_usecase.dart';
import '../../features/appointments/domain/usecases/get_doctor_appointments_usecase.dart';
import '../../features/appointments/domain/usecases/get_user_appointments_usecase.dart';
import '../../features/appointments/presentation/bloc/appointment_bloc.dart';
import '../../features/appointments/presentation/cubit/slots_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/register_as_doctor_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_doctor_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_patient_usecase.dart';
import '../../features/auth/domain/usecases/switch_role_usecase.dart';
import '../../features/auth/domain/usecases/update_profile_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/doctors/data/datasources/doctor_remote_data_source.dart';
import '../../features/doctors/data/repositories/doctor_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctor_repository.dart';
import '../../features/doctors/domain/usecases/get_all_doctors_usecase.dart';
import '../../features/doctors/domain/usecases/get_doctor_by_id_usecase.dart';
import '../../features/doctors/domain/usecases/get_doctors_by_speciality_usecase.dart';
import '../../features/doctors/domain/usecases/search_doctors_usecase.dart';
import '../../features/doctors/presentation/bloc/doctor_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- Local preferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => AppPreferences(prefs));

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // --- Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpPatientUseCase(sl()));
  sl.registerLazySingleton(() => SignUpDoctorUseCase(sl()));
  sl.registerLazySingleton(() => RegisterAsDoctorUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SwitchRoleUseCase(sl()));
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUpPatient: sl(),
      signUpDoctor: sl(),
      registerAsDoctor: sl(),
      updateProfile: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      switchRole: sl(),
    ),
  );

  // --- Doctors
  sl.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetAllDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorByIdUseCase(sl()));
  sl.registerLazySingleton(() => SearchDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorsBySpecialityUseCase(sl()));
  sl.registerFactory(
    () => DoctorBloc(
      getAllDoctors: sl(),
      getDoctorById: sl(),
      searchDoctors: sl(),
      getDoctorsBySpeciality: sl(),
    ),
  );

  // --- Appointments
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => BookAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => GetUserAppointmentsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorAppointmentsUseCase(sl()));
  sl.registerFactory(
    () => AppointmentBloc(
      bookAppointment: sl(),
      getUserAppointments: sl(),
      getDoctorAppointments: sl(),
    ),
  );
  sl.registerFactory(() => SlotsCubit(sl()));
}
