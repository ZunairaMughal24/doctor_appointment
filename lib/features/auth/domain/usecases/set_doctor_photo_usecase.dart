import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_photo_repository.dart';

class SetDoctorPhotoUseCase implements UseCase<String, SetPhotoParams> {
  final ProfilePhotoRepository repository;
  SetDoctorPhotoUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SetPhotoParams params) =>
      repository.setDoctorPhoto(params.uid, params.file);
}

class SetPhotoParams {
  final String uid;
  final File file;
  const SetPhotoParams({required this.uid, required this.file});
}
