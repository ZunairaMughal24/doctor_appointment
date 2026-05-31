import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_doctor_usecase.dart';
import '../../domain/usecases/sign_up_patient_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpPatientUseCase signUpPatient;
  final SignUpDoctorUseCase signUpDoctor;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;

  AuthBloc({
    required this.signIn,
    required this.signUpPatient,
    required this.signUpDoctor,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpPatientRequested>(_onSignUpPatient);
    on<AuthSignUpDoctorRequested>(_onSignUpDoctor);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signIn(
        SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpPatient(
      AuthSignUpPatientRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signUpPatient(SignUpPatientParams(
      name: event.name,
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpDoctor(
      AuthSignUpDoctorRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signUpDoctor(SignUpDoctorParams(
      name: event.name,
      email: event.email,
      password: event.password,
      speciality: event.speciality,
      experience: event.experience,
      phoneNumber: event.phoneNumber,
      location: event.location,
      availability: event.availability,
      services: event.services,
    ));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await signOut(NoParams());
    emit(const AuthUnauthenticated());
  }
}
