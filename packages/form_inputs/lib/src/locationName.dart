import 'package:formz/formz.dart';

enum LocationNameValidationError { invalid }

class LocationName extends FormzInput<String, LocationNameValidationError> {
  const LocationName.pure() : super.pure('');

  const LocationName.dirty([super.value = '']) : super.dirty();

  static final _locationNameRegExp = RegExp(r'^[a-zA-Z0-9\s]+$');

  @override
  LocationNameValidationError? validator(String? value) {
    return _locationNameRegExp.hasMatch(value ?? '')
        ? null
        : LocationNameValidationError.invalid;
  }
}