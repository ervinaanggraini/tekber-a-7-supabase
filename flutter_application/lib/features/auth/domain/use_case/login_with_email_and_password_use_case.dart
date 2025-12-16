import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_application/core/use_cases/use_case.dart';
import 'package:flutter_application/features/auth/domain/repository/auth_repository.dart';

@injectable
class LoginWithEmailAndPasswordUseCase extends UseCase<Future<void>, LoginWithEmailAndPasswordParams> {
  LoginWithEmailAndPasswordUseCase(
    this._authRepository,
  );

  final AuthRepository _authRepository;

  @override
  Future<void> execute(LoginWithEmailAndPasswordParams params) async {
    await _authRepository.loginWithEmailAndPassword(params.email, params.password);
  }
}

class LoginWithEmailAndPasswordParams extends Equatable {
  const LoginWithEmailAndPasswordParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [
        email,
        password,
      ];
}
