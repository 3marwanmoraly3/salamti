import 'package:formz/formz.dart';

enum NationalIdValidationError { invalid }

class NationalId extends FormzInput<String, NationalIdValidationError> {
  const NationalId.pure() : super.pure('');

  const NationalId.dirty([super.value = '']) : super.dirty();

  static final _nationalIdRegExp = RegExp(r'^[\d]{10,10}$');

  @override
  NationalIdValidationError? validator(String? value) {
    return _nationalIdRegExp.hasMatch(value ?? '')
        ? null
        : NationalIdValidationError.invalid;
  }
}
