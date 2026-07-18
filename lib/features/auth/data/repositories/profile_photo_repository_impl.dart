import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/profile_photo_repository.dart';
import '../datasources/profile_photo_remote_data_source.dart';

class ProfilePhotoRepositoryImpl implements ProfilePhotoRepository {
  final ProfilePhotoRemoteDataSource remoteDataSource;

  const ProfilePhotoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> setDoctorPhoto(String uid, File file) async {
    try {
      final url = await remoteDataSource.setDoctorPhoto(uid, file);
      return Right(url);
    } on ImageUploadException catch (e) {
      return Left(ImageUploadFailure(e.message));
    } catch (e) {
      return const Left(ImageUploadFailure(
          'Something went wrong while uploading your photo. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, String>> setUserPhoto(String uid, File file) async {
    try {
      final url = await remoteDataSource.setUserPhoto(uid, file);
      return Right(url);
    } on ImageUploadException catch (e) {
      return Left(ImageUploadFailure(e.message));
    } catch (e) {
      return const Left(ImageUploadFailure(
          'Something went wrong while uploading your photo. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDoctorPhoto(String uid) async {
    try {
      await remoteDataSource.deleteDoctorPhoto(uid);
      return const Right(null);
    } on ImageUploadException catch (e) {
      return Left(ImageUploadFailure(e.message));
    } catch (e) {
      return const Left(
          ImageUploadFailure('Something went wrong while removing your photo.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserPhoto(String uid) async {
    try {
      await remoteDataSource.deleteUserPhoto(uid);
      return const Right(null);
    } on ImageUploadException catch (e) {
      return Left(ImageUploadFailure(e.message));
    } catch (e) {
      return const Left(
          ImageUploadFailure('Something went wrong while removing your photo.'));
    }
  }
}
