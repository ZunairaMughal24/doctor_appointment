import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpPatientUseCase implements UseCase<UserEntity, SignUpPatientParams> {
  final AuthRepository repository;
  SignUpPatientUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpPatientParams params) =>
      repository.signUpPatient(
        name: params.name,
        email: params.email,
        password: params.password,
      );
}

class SignUpPatientParams {
  final String name;
  final String email;
  final String password;
  const SignUpPatientParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
