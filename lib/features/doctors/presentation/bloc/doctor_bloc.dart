import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_all_doctors_usecase.dart';
import '../../domain/usecases/get_doctor_by_id_usecase.dart';
import '../../domain/usecases/get_doctors_by_speciality_usecase.dart';
import '../../domain/usecases/search_doctors_usecase.dart';
import 'doctor_event.dart';
import 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final GetAllDoctorsUseCase getAllDoctors;
  final GetDoctorByIdUseCase getDoctorById;
  final SearchDoctorsUseCase searchDoctors;
  final GetDoctorsBySpecialityUseCase getDoctorsBySpeciality;

  DoctorBloc({
    required this.getAllDoctors,
    required this.getDoctorById,
    required this.searchDoctors,
    required this.getDoctorsBySpeciality,
  }) : super(const DoctorInitial()) {
    on<LoadAllDoctors>(_onLoadAll);
    on<LoadDoctorById>(_onLoadById);
    on<SearchDoctors>(_onSearch);
    on<LoadDoctorsBySpeciality>(_onLoadBySpeciality);
  }

  Future<void> _onLoadAll(
      LoadAllDoctors event, Emitter<DoctorState> emit) async {
    // Repository always returns data (seeds or Firestore) — no loading state needed
    final result = await getAllDoctors(NoParams());
    result.fold(
      (failure) => emit(DoctorError(failure.message)),
      (doctors) => emit(DoctorsLoaded(doctors)),
    );
  }

  Future<void> _onLoadById(
      LoadDoctorById event, Emitter<DoctorState> emit) async {
    emit(const DoctorLoading());
    final result = await getDoctorById(event.id);
    result.fold(
      (failure) => emit(DoctorError(failure.message)),
      (doctor) => emit(DoctorDetailLoaded(doctor)),
    );
  }

  Future<void> _onSearch(
      SearchDoctors event, Emitter<DoctorState> emit) async {
    emit(const DoctorLoading());
    final result = await searchDoctors(event.query);
    result.fold(
      (failure) => emit(DoctorError(failure.message)),
      (doctors) => emit(DoctorsLoaded(doctors)),
    );
  }

  Future<void> _onLoadBySpeciality(
      LoadDoctorsBySpeciality event, Emitter<DoctorState> emit) async {
    emit(const DoctorLoading());
    final result = await getDoctorsBySpeciality(event.speciality);
    result.fold(
      (failure) => emit(DoctorError(failure.message)),
      (doctors) => emit(DoctorsLoaded(doctors)),
    );
  }
}
