import 'package:flutter_application/core/extensions/string_extensions.dart';
import 'package:formz/formz.dart';

enum PasswordValidationError {
  invalid,
}

class PasswordValueObject extends FormzInput<String, PasswordValidationError> {
  const PasswordValueObject.pure() : super.pure('');

  const PasswordValueObject.dirty([
    super.value = '',
  ]) : super.dirty();

  @override
  PasswordValidationError? validator(String? value) {
    if (value.isNullOrEmpty) return PasswordValidationError.invalid;
    if (value!.length < 6) return PasswordValidationError.invalid;

    return null;
  }
}
