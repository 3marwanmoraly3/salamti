import 'package:formz/formz.dart';

enum SmsCodeValidationError {
  invalid
}

class SmsCode extends FormzInput<String, SmsCodeValidationError> {
  const SmsCode.pure() : super.pure('');

  const SmsCode.dirty([super.value = '']) : super.dirty();

  static final _smsCodeRegExp =
  RegExp(r'^[\d]{4,4}$');

  @override
  SmsCodeValidationError? validator(String? value) {
    return _smsCodeRegExp.hasMatch(value ?? '')
        ? null
        : SmsCodeValidationError.invalid;
  }
}