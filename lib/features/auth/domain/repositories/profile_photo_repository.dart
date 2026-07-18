import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class ProfilePhotoRepository {
  Future<Either<Failure, String>> setDoctorPhoto(String uid, File file);
  Future<Either<Failure, String>> setUserPhoto(String uid, File file);
  Future<Either<Failure, void>> deleteDoctorPhoto(String uid);
  Future<Either<Failure, void>> deleteUserPhoto(String uid);
}
