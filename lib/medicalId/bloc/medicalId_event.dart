part of 'medicalId_bloc.dart';

sealed class MedicalIdEvent {
  const MedicalIdEvent();
}

final class InitialCheck extends MedicalIdEvent {
  const InitialCheck();
}

final class ResetFormStatus extends MedicalIdEvent {
  const ResetFormStatus();
}

final class ConditionChanged extends MedicalIdEvent {
  final String condition;

  const ConditionChanged(this.condition);
}

final class AllergyChanged extends MedicalIdEvent {
  final String allergy;

  const AllergyChanged(this.allergy);
}

final class MedicationChanged extends MedicalIdEvent {
  final String medication;

  const MedicationChanged(this.medication);
}

final class GenderChanged extends MedicalIdEvent {
  final String gender;

  const GenderChanged(this.gender);
}

final class BloodTypeChanged extends MedicalIdEvent {
  final String bloodType;

  const BloodTypeChanged(this.bloodType);
}

final class DOBChanged extends MedicalIdEvent {
  final String dob;

  const DOBChanged(this.dob);
}

final class AddCondition extends MedicalIdEvent {
  final String condition;

  const AddCondition(this.condition);
}

final class RemoveCondition extends MedicalIdEvent {
  final int index;

  const RemoveCondition(this.index);
}

final class AddAllergy extends MedicalIdEvent {
  final String allergy;

  const AddAllergy(this.allergy);
}

final class RemoveAllergy extends MedicalIdEvent {
  final int index;

  const RemoveAllergy(this.index);
}

final class AddMedication extends MedicalIdEvent {
  final String medication;

  const AddMedication(this.medication);
}

final class RemoveMedication extends MedicalIdEvent {
  final int index;

  const RemoveMedication(this.index);
}