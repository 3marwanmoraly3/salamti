part of 'emergencyContacts_bloc.dart';

sealed class EmergencyContactsEvent {
  const EmergencyContactsEvent();
}

final class UpdateEmergencyContacts extends EmergencyContactsEvent {
  const UpdateEmergencyContacts();
}

final class ResetFormStatus extends EmergencyContactsEvent {
  const ResetFormStatus();
}

final class FormDismissed extends EmergencyContactsEvent {
  const FormDismissed();
}

final class NameChanged extends EmergencyContactsEvent {
  final String name;

  const NameChanged(this.name);
}

final class PhoneChanged extends EmergencyContactsEvent {
  final String phone;

  const PhoneChanged(this.phone);
}

final class EmergencyContactAddition extends EmergencyContactsEvent {
  const EmergencyContactAddition();
}

final class EmergencyContactEdit extends EmergencyContactsEvent {
  final int index;

  const EmergencyContactEdit(this.index);
}

final class EmergencyContactRemoval extends EmergencyContactsEvent {
  final String name;
  final String phone;

  const EmergencyContactRemoval({required this.name, required this.phone});
}
