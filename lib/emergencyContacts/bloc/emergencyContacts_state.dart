part of 'emergencyContacts_bloc.dart';

enum UpdateContactStatus { loading, initial, remove, success }

final class EmergencyContactsState extends Equatable {
  const EmergencyContactsState({
    this.name = const Name.pure(),
    this.phone = const Phone.pure(),
    this.status = UpdateContactStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    required this.emergencyContacts,
  });

  final Name name;
  final Phone phone;
  final UpdateContactStatus status;
  final FormzSubmissionStatus formStatus;
  final bool isValid;
  final String? errorMessage;
  final List<dynamic> emergencyContacts;

  @override
  List<Object?> get props => [
        name,
        phone,
        status,
        formStatus,
        isValid,
        errorMessage,
        emergencyContacts,
      ];

  EmergencyContactsState copyWith({
    Name? name,
    Phone? phone,
    UpdateContactStatus? status,
    FormzSubmissionStatus? formStatus,
    bool? isValid,
    String? errorMessage,
    required List<dynamic> emergencyContacts,
  }) {
    return EmergencyContactsState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      formStatus: formStatus ?? this.formStatus,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      emergencyContacts: emergencyContacts,
    );
  }
}
