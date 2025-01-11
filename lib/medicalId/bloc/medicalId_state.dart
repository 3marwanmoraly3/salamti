part of 'medicalId_bloc.dart';


final class MedicalIdState extends Equatable {
  const MedicalIdState({
    this.conditions,
    this.allergies,
    this.medications,
    this.conditionInput = const MedicalInfo.pure(),
    this.allergyInput = const MedicalInfo.pure(),
    this.medicationInput = const MedicalInfo.pure(),
    this.bloodType = "",
    this.gender = "",
    this.dob = "",
    this.loading = true,
    this.formStatus = FormzSubmissionStatus.initial,
    this.isConditionValid = false,
    this.isAllergyValid = false,
    this.isMedicationValid = false,
    this.errorMessage,
  });

  final List<dynamic>? conditions;
  final List<dynamic>? allergies;
  final List<dynamic>? medications;
  final MedicalInfo conditionInput;
  final MedicalInfo allergyInput;
  final MedicalInfo medicationInput;
  final String bloodType;
  final String gender;
  final String dob;
  final bool loading;
  final FormzSubmissionStatus formStatus;
  final bool isConditionValid;
  final bool isAllergyValid;
  final bool isMedicationValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        conditions,
        allergies,
        medications,
        conditionInput,
        allergyInput,
        medicationInput,
        bloodType,
        gender,
        dob,
        loading,
        formStatus,
        isConditionValid,
        isAllergyValid,
        isMedicationValid,
        errorMessage,
      ];

  MedicalIdState copyWith({
    List<dynamic>? conditions,
    List<dynamic>? allergies,
    List<dynamic>? medications,
    MedicalInfo? conditionInput,
    MedicalInfo? allergyInput,
    MedicalInfo? medicationInput,
    String? bloodType,
    String? gender,
    String? dob,
    bool? loading,
    FormzSubmissionStatus? formStatus,
    bool? isConditionValid,
    bool? isAllergyValid,
    bool? isMedicationValid,
    String? errorMessage,
  }) {
    return MedicalIdState(
        conditions: conditions ?? this.conditions,
        allergies: allergies ?? this.allergies,
        medications: medications ?? this.medications,
        conditionInput: conditionInput ?? this.conditionInput,
        allergyInput: allergyInput ?? this.allergyInput,
        medicationInput: medicationInput ?? this.medicationInput,
        bloodType: bloodType ?? this.bloodType,
        gender: gender ?? this.gender,
        dob: dob ?? this.dob,
        loading: loading ?? this.loading,
        formStatus: formStatus ?? this.formStatus,
        isConditionValid: isConditionValid ?? this.isConditionValid,
        isAllergyValid: isAllergyValid ?? this.isAllergyValid,
        isMedicationValid: isMedicationValid ?? this.isMedicationValid,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
