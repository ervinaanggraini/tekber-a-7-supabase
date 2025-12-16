import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/value_objects/email_value_object.dart';
import 'package:flutter_application/core/value_objects/password_value_object.dart';
import 'package:flutter_application/features/auth/domain/exception/login_with_email_exception.dart';
import 'package:flutter_application/features/auth/domain/use_case/sign_up_with_email_and_password_use_case.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

part 'register_state.dart';

@injectable
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(
    this._signUpWithEmailAndPasswordUseCase,
  ) : super(const RegisterState());

  final SignUpWithEmailAndPasswordUseCase _signUpWithEmailAndPasswordUseCase;

  void nameChanged(String value) {
    emit(state.copyWith(
      name: value,
      isValid: _validateForm(
        name: value,
        email: state.email,
        password: state.password,
        confirmPassword: state.confirmPassword,
      ),
    ));
  }

  void emailChanged(String value) {
    final email = EmailValueObject.dirty(value);

    emit(state.copyWith(
      email: email,
      isValid: _validateForm(
        name: state.name,
        email: email,
        password: state.password,
        confirmPassword: state.confirmPassword,
      ),
    ));
  }

  void passwordChanged(String value) {
    final password = PasswordValueObject.dirty(value);

    emit(state.copyWith(
      password: password,
      isValid: _validateForm(
        name: state.name,
        email: state.email,
        password: password,
        confirmPassword: state.confirmPassword,
      ),
    ));
  }

  void confirmPasswordChanged(String value) {
    emit(state.copyWith(
      confirmPassword: value,
      isValid: _validateForm(
        name: state.name,
        email: state.email,
        password: state.password,
        confirmPassword: value,
      ),
    ));
  }

  bool _validateForm({
    required String name,
    required EmailValueObject email,
    required PasswordValueObject password,
    required String confirmPassword,
  }) {
    return name.length >= 3 &&
        Formz.validate([email, password]) &&
        password.value == confirmPassword &&
        confirmPassword.isNotEmpty;
  }

  Future<void> submitForm() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      await _signUpWithEmailAndPasswordUseCase.execute(
        SignUpWithEmailAndPasswordParams(
          email: state.email.value,
          password: state.password.value,
        ),
      );

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LoginWithEmailException catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.message,
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      emit(
        state.copyWith(
          errorMessage: 'Failed to sign up. Please try again.',
          status: FormzSubmissionStatus.failure,
        ),
      );
    }
  }
}
