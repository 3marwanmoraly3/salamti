import 'package:formz/formz.dart';

enum StringQuestionValidationError { invalid }

class StringQuestion extends FormzInput<String, StringQuestionValidationError> {
  const StringQuestion.pure() : super.pure('');

  const StringQuestion.dirty([super.value = '']) : super.dirty();

  static final _stringQuestionRegExp = RegExp(r'^[a-zA-Z0-9\s]*$');

  @override
  StringQuestionValidationError? validator(String? value) {
    return _stringQuestionRegExp.hasMatch(value ?? '')
        ? null
        : StringQuestionValidationError.invalid;
  }
}
