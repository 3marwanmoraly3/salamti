import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'emergencyContacts_state.dart';
part 'emergencyContacts_event.dart';

class EmergencyContactsBloc
    extends Bloc<EmergencyContactsEvent, EmergencyContactsState> {
  EmergencyContactsBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(const EmergencyContactsState(emergencyContacts: [])) {
    on<UpdateEmergencyContacts>(_onUpdateEmergencyContacts);
    on<ResetFormStatus>(_onResetFormStatus);
    on<FormDismissed>(_onFormDismissed);
    on<NameChanged>(_onNameChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<EmergencyContactAddition>(_onEmergencyContactAddition);
    on<EmergencyContactEdit>(_onEmergencyContactEdit);
    on<EmergencyContactRemoval>(_onEmergencyContactRemoval);
    add(const UpdateEmergencyContacts());
    add(const ResetFormStatus());
  }

  final AuthenticationRepository _authenticationRepository;

  void _onUpdateEmergencyContacts(UpdateEmergencyContacts event,
      Emitter<EmergencyContactsState> emit) async {
    List<dynamic> contacts =
        await _authenticationRepository.getEmergencyContacts();
    emit(state.copyWith(emergencyContacts: contacts));
  }

  void _onResetFormStatus(
      ResetFormStatus event, Emitter<EmergencyContactsState> emit) {
    emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        status: UpdateContactStatus.initial,
        emergencyContacts: state.emergencyContacts));
  }

  void _onFormDismissed(
      FormDismissed event, Emitter<EmergencyContactsState> emit) {
    emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        isValid: false,
        name: const Name.pure(),
        phone: const Phone.pure(),
        emergencyContacts: state.emergencyContacts));
  }

  void _onNameChanged(NameChanged event, Emitter<EmergencyContactsState> emit) {
    final name = Name.dirty(event.name);
    emit(
      state.copyWith(
          name: name,
          isValid: Formz.validate([
            name,
            state.phone,
          ]),
          emergencyContacts: state.emergencyContacts),
    );
  }

  void _onPhoneChanged(
      PhoneChanged event, Emitter<EmergencyContactsState> emit) {
    final phone = Phone.dirty(event.phone);
    emit(
      state.copyWith(
          phone: phone,
          isValid: Formz.validate([
            state.name,
            phone,
          ]),
          emergencyContacts: state.emergencyContacts),
    );
  }

  Future<void> _onEmergencyContactAddition(EmergencyContactAddition event,
      Emitter<EmergencyContactsState> emit) async {
    try {
      emit(state.copyWith(
          formStatus: FormzSubmissionStatus.inProgress,
          emergencyContacts: state.emergencyContacts));
      await _authenticationRepository.addEmergencyContact(
        name: state.name.value,
        phone: state.phone.value,
      );
      add(const UpdateEmergencyContacts());
      emit(state.copyWith(
          formStatus: FormzSubmissionStatus.success,
          status: UpdateContactStatus.success,
          isValid: false,
          name: const Name.pure(),
          phone: const Phone.pure(),
          emergencyContacts: state.emergencyContacts));
    } catch (e) {
      emit(
        state.copyWith(
            errorMessage: e.toString(),
            formStatus: FormzSubmissionStatus.failure,
            emergencyContacts: state.emergencyContacts),
      );
    }
  }

  Future<void> _onEmergencyContactEdit(EmergencyContactEdit event,
      Emitter<EmergencyContactsState> emit) async {
    try {
      emit(state.copyWith(
          formStatus: FormzSubmissionStatus.inProgress,
          emergencyContacts: state.emergencyContacts));
      await _authenticationRepository.editEmergencyContact(
        name: state.name.value,
        phone: state.phone.value,
        index: event.index,
      );
      add(const UpdateEmergencyContacts());
      emit(state.copyWith(
          formStatus: FormzSubmissionStatus.success,
          status: UpdateContactStatus.success,
          isValid: false,
          name: const Name.pure(),
          phone: const Phone.pure(),
          emergencyContacts: state.emergencyContacts));
    } catch (e) {
      emit(
        state.copyWith(
            errorMessage: e.toString(),
            formStatus: FormzSubmissionStatus.failure,
            emergencyContacts: state.emergencyContacts),
      );
    }
  }

  Future<void> _onEmergencyContactRemoval(EmergencyContactRemoval event,
      Emitter<EmergencyContactsState> emit) async {
    try {
      emit(state.copyWith(
          status: UpdateContactStatus.remove,
          emergencyContacts: state.emergencyContacts));
      await _authenticationRepository.removeEmergencyContact(
        name: event.name,
        phone: event.phone,
      );
      add(const UpdateEmergencyContacts());
      emit(state.copyWith(
          formStatus: FormzSubmissionStatus.success,
          status: UpdateContactStatus.success,
          isValid: false,
          name: const Name.pure(),
          phone: const Phone.pure(),
          emergencyContacts: state.emergencyContacts));
    } catch (e) {
      emit(
        state.copyWith(
            errorMessage: e.toString(),
            formStatus: FormzSubmissionStatus.failure,
            emergencyContacts: state.emergencyContacts),
      );
    }
  }
}
