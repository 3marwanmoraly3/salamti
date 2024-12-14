import 'package:formz/formz.dart';

enum PhoneValidationError {
  invalid
}

class Phone extends FormzInput<String, PhoneValidationError> {
  const Phone.pure() : super.pure('');
  
  const Phone.dirty([super.value = '']) : super.dirty();

  static final _phoneRegExp =
  RegExp(r'^7(5|7|8|9)[\d]{7,7}$');

  @override
  PhoneValidationError? validator(String? value) {
    return _phoneRegExp.hasMatch(value ?? '')
        ? null
        : PhoneValidationError.invalid;
  }
}