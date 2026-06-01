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
    on<LoadUserAppointments>(_onLoadUser);
    on<LoadDoctorAppointments>(_onLoadDoctor);
    on<BookAppointment>(_onBook);
  }

  Future<void> _onLoadUser(
      LoadUserAppointments event, Emitter<AppointmentState> emit) async {
    final hadData = state is AppointmentsLoaded;
    // Only show a spinner on the very first load — subsequent calls refresh silently.
    if (!hadData) emit(const AppointmentLoading());

    final result = await getUserAppointments(event.patientId);
    result.fold(
      (failure) { if (!hadData) emit(AppointmentError(failure.message)); },
      (appointments) => emit(AppointmentsLoaded(appointments)),
    );
  }

  Future<void> _onLoadDoctor(
      LoadDoctorAppointments event, Emitter<AppointmentState> emit) async {
    final hadData = state is AppointmentsLoaded;
    if (!hadData) emit(const AppointmentLoading());

    final result = await getDoctorAppointments(event.doctorId);
    result.fold(
      (failure) { if (!hadData) emit(AppointmentError(failure.message)); },
      (appointments) => emit(AppointmentsLoaded(appointments)),
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
