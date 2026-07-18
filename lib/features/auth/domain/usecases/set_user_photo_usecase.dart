import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_photo_repository.dart';
import 'set_doctor_photo_usecase.dart' show SetPhotoParams;

class SetUserPhotoUseCase implements UseCase<String, SetPhotoParams> {
  final ProfilePhotoRepository repository;
  SetUserPhotoUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SetPhotoParams params) =>
      repository.setUserPhoto(params.uid, params.file);
}
