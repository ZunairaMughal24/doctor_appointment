import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SwitchRoleUseCase extends UseCase<void, SwitchRoleParams> {
  final AuthRepository repository;
  SwitchRoleUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SwitchRoleParams params) =>
      repository.switchRole(uid: params.uid, role: params.role);
}

class SwitchRoleParams extends Equatable {
  final String uid;
  final UserRole role;
  const SwitchRoleParams({required this.uid, required this.role});

  @override
  List<Object?> get props => [uid, role];
}
