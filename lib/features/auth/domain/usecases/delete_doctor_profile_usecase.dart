import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class DeleteDoctorProfileParams extends Equatable {
  final String uid;
  final String name;
  final String email;
  const DeleteDoctorProfileParams({
    required this.uid,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, name, email];
}

/// Removes a doctor's professional profile and returns the resulting patient
/// user (the account stays signed in, now as a patient).
class DeleteDoctorProfileUseCase
    implements UseCase<UserEntity, DeleteDoctorProfileParams> {
  final AuthRepository repository;
  DeleteDoctorProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(DeleteDoctorProfileParams params) =>
      repository.deleteDoctorProfile(
        uid: params.uid,
        name: params.name,
        email: params.email,
      );
}
