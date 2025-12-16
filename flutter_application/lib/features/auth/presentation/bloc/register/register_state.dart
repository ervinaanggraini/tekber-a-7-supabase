part of 'register_cubit.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.name = '',
    this.email = const EmailValueObject.pure(),
    this.password = const PasswordValueObject.pure(),
    this.confirmPassword = '',
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  final String name;
  final EmailValueObject email;
  final PasswordValueObject password;
  final String confirmPassword;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        confirmPassword,
        status,
        isValid,
        errorMessage,
      ];

  RegisterState copyWith({
    String? name,
    EmailValueObject? email,
    PasswordValueObject? password,
    String? confirmPassword,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
