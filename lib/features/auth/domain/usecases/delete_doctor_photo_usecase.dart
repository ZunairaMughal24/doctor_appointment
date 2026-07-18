import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_photo_repository.dart';

class DeleteDoctorPhotoUseCase implements UseCase<void, String> {
  final ProfilePhotoRepository repository;
  DeleteDoctorPhotoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String uid) =>
      repository.deleteDoctorPhoto(uid);
}
