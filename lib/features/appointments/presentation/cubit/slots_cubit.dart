import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_doctor_appointments_usecase.dart';

// ── State ─────────────────────────────────────────────────────────────────────

abstract class SlotsState extends Equatable {
  const SlotsState();
  @override
  List<Object?> get props => [];
}

class SlotsInitial extends SlotsState {
  const SlotsInitial();
}

class SlotsLoading extends SlotsState {
  const SlotsLoading();
}

class SlotsLoaded extends SlotsState {
  /// Times ('HH:mm') already booked for the selected doctor + date.
  final List<String> bookedTimes;
  const SlotsLoaded(this.bookedTimes);
  @override
  List<Object?> get props => [bookedTimes];
}

class SlotsError extends SlotsState {
  final String message;
  const SlotsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

/// Loads which time slots are already taken for a doctor on a given date,
/// so the booking screen can disable them (live availability).
class SlotsCubit extends Cubit<SlotsState> {
  final GetDoctorAppointmentsUseCase getDoctorAppointments;

  SlotsCubit(this.getDoctorAppointments) : super(const SlotsInitial());

  Future<void> loadBookedTimes({
    required String doctorId,
    required String date,
  }) async {
    emit(const SlotsLoading());
    final result = await getDoctorAppointments(doctorId);
    result.fold(
      (failure) => emit(SlotsError(failure.message)),
      (appointments) {
        final booked = appointments
            .where((a) => a.appointmentDate == date)
            .map((a) => a.appointmentTime)
            .where((t) => t.isNotEmpty)
            .toList();
        emit(SlotsLoaded(booked));
      },
    );
  }
}
