part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = const EmailValueObject.pure(),
    this.password = const PasswordValueObject.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.isLoginMode = true,
  });

  final EmailValueObject email;
  final PasswordValueObject password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;
  final bool isLoginMode;

  @override
  List<Object> get props => [
        email,
        password,
        status,
        isValid,
        isLoginMode,
      ];

  LoginState copyWith({
    EmailValueObject? email,
    PasswordValueObject? password,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
    bool? isLoginMode,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoginMode: isLoginMode ?? this.isLoginMode,
    );
  }
}
