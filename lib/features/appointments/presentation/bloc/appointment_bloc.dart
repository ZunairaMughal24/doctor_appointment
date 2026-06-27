import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/book_appointment_usecase.dart';
import '../../domain/usecases/get_doctor_appointments_usecase.dart';
import '../../domain/usecases/get_user_appointments_usecase.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final BookAppointmentUseCase bookAppointment;
  final GetUserAppointmentsUseCase getUserAppointments;
  final GetDoctorAppointmentsUseCase getDoctorAppointments;

  AppointmentBloc({
    required this.bookAppointment,
    required this.getUserAppointments,
    required this.getDoctorAppointments,
  }) : super(const AppointmentInitial()) {
    on<LoadUserAppointments>(_onLoadUser, transformer: restartable());
    on<LoadDoctorAppointments>(_onLoadDoctor, transformer: restartable());
    on<BookAppointment>(_onBook);
  }

  Future<void> _onLoadUser(
      LoadUserAppointments event, Emitter<AppointmentState> emit) async {
    if (state is! AppointmentsLoaded) emit(const AppointmentLoading());
    await emit.forEach(
      getUserAppointments(event.patientId),
      onData: (appointments) => AppointmentsLoaded(appointments),
      onError: (_, __) => state is AppointmentsLoaded
          ? state
          : const AppointmentError('Failed to load appointments'),
    );
  }

  Future<void> _onLoadDoctor(
      LoadDoctorAppointments event, Emitter<AppointmentState> emit) async {
    if (state is! AppointmentsLoaded) emit(const AppointmentLoading());
    await emit.forEach(
      getDoctorAppointments(event.doctorId),
      onData: (appointments) => AppointmentsLoaded(appointments),
      onError: (_, __) => state is AppointmentsLoaded
          ? state
          : const AppointmentError('Failed to load appointments'),
    );
  }

  Future<void> _onBook(
      BookAppointment event, Emitter<AppointmentState> emit) async {
    emit(const AppointmentLoading());
    final result = await bookAppointment(event.appointment);
    result.fold(
      (failure) => emit(AppointmentError(failure.message)),
      (_) => emit(const AppointmentBooked()),
    );
  }
}
