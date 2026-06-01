import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) =>
      repository.updateProfile(
        uid: params.uid,
        name: params.name,
        email: params.email,
      );
}

class UpdateProfileParams {
  final String uid;
  final String name;
  final String email;
  const UpdateProfileParams({
    required this.uid,
    required this.name,
    required this.email,
  });
}
