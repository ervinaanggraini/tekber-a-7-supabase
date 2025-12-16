import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/value_objects/email_value_object.dart';
import 'package:flutter_application/core/value_objects/password_value_object.dart';
import 'package:flutter_application/features/auth/domain/exception/login_with_email_exception.dart';

import 'package:flutter_application/features/auth/domain/use_case/login_with_email_and_password_use_case.dart';
import 'package:flutter_application/features/auth/domain/use_case/sign_up_with_email_and_password_use_case.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter/foundation.dart';

part 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._loginWithEmailAndPasswordUseCase,
    this._signUpWithEmailAndPasswordUseCase,
  ) : super(
          const LoginState(),
        );

  final LoginWithEmailAndPasswordUseCase _loginWithEmailAndPasswordUseCase;
  final SignUpWithEmailAndPasswordUseCase _signUpWithEmailAndPasswordUseCase;

  void emailChanged(String value) {
    final email = EmailValueObject.dirty(value);

    emit(state.copyWith(
      email: email,
      isValid: Formz.validate([
        email,
        state.password,
      ]),
    ));
  }

  void passwordChanged(String value) {
    final password = PasswordValueObject.dirty(value);

    emit(state.copyWith(
      password: password,
      isValid: Formz.validate([
        state.email,
        password,
      ]),
    ));
  }

  void toggleLoginMode() {
    emit(state.copyWith(
      isLoginMode: !state.isLoginMode,
    ));
  }

  void setLoginMode(bool isLogin) {
    emit(state.copyWith(
      isLoginMode: isLogin,
    ));
  }

  void submitForm() async {
    if (!state.isValid) return;

    emit(
      state.copyWith(status: FormzSubmissionStatus.inProgress),
    );

    try {
      if (state.isLoginMode) {
        await _loginWithEmailAndPasswordUseCase.execute(
          LoginWithEmailAndPasswordParams(
            email: state.email.value,
            password: state.password.value,
          ),
        );
      } else {
        await _signUpWithEmailAndPasswordUseCase.execute(
          SignUpWithEmailAndPasswordParams(
            email: state.email.value,
            password: state.password.value,
          ),
        );
      }

      emit(
        state.copyWith(status: FormzSubmissionStatus.success),
      );
    } on Exception catch (e) {
      debugPrint("LoginCubit Error: $e");
      emit(state.copyWith(
        errorMessage: e is LoginWithEmailException ? e.message : e.toString(),
        status: FormzSubmissionStatus.failure,
      ));
    }
  }
}
