import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_application/core/use_cases/use_case.dart';
import 'package:flutter_application/features/auth/domain/repository/auth_repository.dart';

@injectable
class SignUpWithEmailAndPasswordUseCase extends UseCase<Future<void>, SignUpWithEmailAndPasswordParams> {
  SignUpWithEmailAndPasswordUseCase(
    this._authRepository,
  );

  final AuthRepository _authRepository;

  @override
  Future<void> execute(SignUpWithEmailAndPasswordParams params) async {
    await _authRepository.signUpWithEmailAndPassword(params.email, params.password);
  }
}

class SignUpWithEmailAndPasswordParams extends Equatable {
  const SignUpWithEmailAndPasswordParams({
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
