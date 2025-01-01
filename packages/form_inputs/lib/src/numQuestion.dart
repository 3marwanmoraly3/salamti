import 'package:formz/formz.dart';

enum NumQuestionValidationError { invalid }

class NumQuestion extends FormzInput<String, NumQuestionValidationError> {
  const NumQuestion.pure() : super.pure('');

  const NumQuestion.dirty([super.value = '']) : super.dirty();

  static final _numQuestionRegExp = RegExp(r'^\d{0,2}$');

  @override
  NumQuestionValidationError? validator(String? value) {
    return _numQuestionRegExp.hasMatch(value ?? '')
        ? null
        : NumQuestionValidationError.invalid;
  }
}
