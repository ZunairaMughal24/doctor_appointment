import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/register_as_doctor_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_doctor_usecase.dart';
import '../../domain/usecases/sign_up_patient_usecase.dart';
import '../../domain/usecases/switch_role_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../../core/services/push_notification_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpPatientUseCase signUpPatient;
  final SignUpDoctorUseCase signUpDoctor;
  final RegisterAsDoctorUseCase registerAsDoctor;
  final UpdateProfileUseCase updateProfile;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;
  final SwitchRoleUseCase switchRole;

  AuthBloc({
    required this.signIn,
    required this.signUpPatient,
    required this.signUpDoctor,
    required this.registerAsDoctor,
    required this.updateProfile,
    required this.signOut,
    required this.getCurrentUser,
    required this.switchRole,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpPatientRequested>(_onSignUpPatient);
    on<AuthSignUpDoctorRequested>(_onSignUpDoctor);
    on<AuthRegisterAsDoctorRequested>(_onRegisterAsDoctor);
    on<AuthUpdateProfileRequested>(_onUpdateProfile);
    on<AuthSwitchRoleRequested>(_onSwitchRole);
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
      (failure) => emit(AuthFailureState(failure.userMessage)),
      (user) {
        emit(AuthAuthenticated(user));
        PushNotificationService.updateDeviceToken();
      },
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
      (failure) => emit(AuthFailureState(failure.userMessage)),
      (user) {
        emit(AuthAuthenticated(user));
        PushNotificationService.updateDeviceToken();
      },
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
      description: event.description,
    ));
    result.fold(
      (failure) => emit(AuthFailureState(failure.userMessage)),
      (user) {
        emit(AuthAuthenticated(user));
        PushNotificationService.updateDeviceToken();
      },
    );
  }

  Future<void> _onRegisterAsDoctor(
      AuthRegisterAsDoctorRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await registerAsDoctor(RegisterAsDoctorParams(
      uid: event.uid,
      name: event.name,
      email: event.email,
      speciality: event.speciality,
      experience: event.experience,
      phoneNumber: event.phoneNumber,
      location: event.location,
      availability: event.availability,
      services: event.services,
    ));
    result.fold(
      (failure) => emit(AuthFailureState(failure.userMessage)),
      (user) {
        emit(AuthAuthenticated(user));
        PushNotificationService.updateDeviceToken();
      },
    );
  }

  Future<void> _onUpdateProfile(
      AuthUpdateProfileRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    emit(const AuthLoading());
    final result = await updateProfile(UpdateProfileParams(
      uid: event.uid,
      name: event.name,
      email: event.email,
      speciality: event.speciality,
      experience: event.experience,
      phoneNumber: event.phoneNumber,
      location: event.location,
      availability: event.availability,
      services: event.services,
      description: event.description,
    ));
    result.fold(
      (failure) {
        // Restore previous state on failure so the user stays logged in
        if (currentState is AuthAuthenticated) {
          emit(AuthFailureState(failure.userMessage));
          emit(currentState);
        } else {
          emit(AuthFailureState(failure.userMessage));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSwitchRole(
      AuthSwitchRoleRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    // Optimistically update UI
    emit(AuthAuthenticated(currentState.user.copyWith(role: event.role)));

    // Persist to Firestore; on failure, revert
    final result = await switchRole(
        SwitchRoleParams(uid: currentState.user.uid, role: event.role));
    result.fold(
      (failure) => emit(currentState),
      (_) {},
    );
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await signOut(NoParams());
    emit(const AuthUnauthenticated());
  }
}
