import 'package:formz/formz.dart';

enum MedicalInfoValidationError { invalid }

class MedicalInfo extends FormzInput<String, MedicalInfoValidationError> {
  const MedicalInfo.pure() : super.pure('');

  const MedicalInfo.dirty([super.value = '']) : super.dirty();

  static final _medicalInfoRegExp = RegExp(r'^[a-zA-Z0-9\s]+$');

  @override
  MedicalInfoValidationError? validator(String? value) {
    return _medicalInfoRegExp.hasMatch(value ?? '')
        ? null
        : MedicalInfoValidationError.invalid;
  }
}