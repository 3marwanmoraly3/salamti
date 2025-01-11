import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'medicalId_state.dart';
part 'medicalId_event.dart';

class MedicalIdBloc extends Bloc<MedicalIdEvent, MedicalIdState> {
  MedicalIdBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(const MedicalIdState()) {
    on<ResetFormStatus>(_onResetFormStatus);
    on<ConditionChanged>(_onConditionChanged);
    on<AllergyChanged>(_onAllergyChanged);
    on<MedicationChanged>(_onMedicationChanged);
    on<GenderChanged>(_onGenderChanged);
    on<BloodTypeChanged>(_onBloodTypeChanged);
    on<DOBChanged>(_onDOBChanged);
    on<AddCondition>(_onAddCondition);
    on<RemoveCondition>(_onRemoveCondition);
    on<AddAllergy>(_onAddAllergy);
    on<RemoveAllergy>(_onRemoveAllergy);
    on<AddMedication>(_onAddMedication);
    on<RemoveMedication>(_onRemoveMedication);
    on<InitialCheck>(_onInitialCheck);
    add(const InitialCheck());
  }

  final AuthenticationRepository _authenticationRepository;

  void _onInitialCheck(InitialCheck event, Emitter<MedicalIdState> emit) async {
    try {
      final Map<String, dynamic> civilianData =
          await _authenticationRepository.getCivilianData();

      final String dob = civilianData["DOB"];
      final String gender = civilianData["Gender"];
      final String bloodType = civilianData["BloodType"];

      final List<dynamic> conditions = civilianData["Conditions"];
      final List<dynamic> allergies = civilianData["Allergies"];
      final List<dynamic> medications = civilianData["Medications"];

      emit(
        state.copyWith(
          dob: dob,
          gender: gender,
          bloodType: bloodType,
          conditions: conditions,
          allergies: allergies,
          medications: medications,
          loading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onResetFormStatus(ResetFormStatus event, Emitter<MedicalIdState> emit) {
    emit(state.copyWith(formStatus: FormzSubmissionStatus.initial));
  }

  void _onConditionChanged(
      ConditionChanged event, Emitter<MedicalIdState> emit) {
    final condition = MedicalInfo.dirty(event.condition);
    emit(
      state.copyWith(
        conditionInput: condition,
        isConditionValid: Formz.validate([
          condition,
        ]),
      ),
    );
  }

  void _onAllergyChanged(AllergyChanged event, Emitter<MedicalIdState> emit) {
    final allergy = MedicalInfo.dirty(event.allergy);
    emit(
      state.copyWith(
        allergyInput: allergy,
        isAllergyValid: Formz.validate([
          allergy,
        ]),
      ),
    );
  }

  void _onMedicationChanged(
      MedicationChanged event, Emitter<MedicalIdState> emit) {
    final medication = MedicalInfo.dirty(event.medication);
    emit(
      state.copyWith(
        medicationInput: medication,
        isMedicationValid: Formz.validate([
          medication,
        ]),
      ),
    );
  }

  void _onGenderChanged(
      GenderChanged event, Emitter<MedicalIdState> emit) async {
    try {
      await _authenticationRepository.updateGender(event.gender);
      emit(
        state.copyWith(
          gender: event.gender,
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onBloodTypeChanged(
      BloodTypeChanged event, Emitter<MedicalIdState> emit) async {
    try {
      await _authenticationRepository.updateBloodType(event.bloodType);
      emit(
        state.copyWith(
          bloodType: event.bloodType,
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onDOBChanged(DOBChanged event, Emitter<MedicalIdState> emit) async {
    try {
      await _authenticationRepository.updateDOB(event.dob);
      emit(
        state.copyWith(
          dob: event.dob,
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onAddCondition(AddCondition event, Emitter<MedicalIdState> emit) async {
    try {
      List<dynamic> conditions = state.conditions!;
      conditions.add(event.condition);
      await _authenticationRepository.updateConditions(conditions);
      emit(
        state.copyWith(
          conditions: conditions,
          conditionInput: const MedicalInfo.pure(),
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onRemoveCondition(RemoveCondition event, Emitter<MedicalIdState> emit) async {
    try {
      List<dynamic> conditions = state.conditions!;
      conditions.removeAt(event.index);
      await _authenticationRepository.updateConditions(conditions);
      emit(
        state.copyWith(
          conditions: conditions,
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onAddAllergy(AddAllergy event, Emitter<MedicalIdState> emit) async {
    try {
      List<dynamic> allergies = state.allergies!;
      allergies.add(event.allergy);
      await _authenticationRepository.updateAllergies(allergies);
      emit(
        state.copyWith(
          allergies: allergies,
          allergyInput: const MedicalInfo.pure(),
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onRemoveAllergy(RemoveAllergy event, Emitter<MedicalIdState> emit) async {
    try {
      List<dynamic> allergies = state.allergies!;
      allergies.removeAt(event.index);
      await _authenticationRepository.updateAllergies(allergies);
      emit(
        state.copyWith(
          allergies: allergies,
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onAddMedication(AddMedication event, Emitter<MedicalIdState> emit) async {
    try {
      List<dynamic> medications = state.medications!;
      medications.add(event.medication);
      await _authenticationRepository.updateMedications(medications);
      emit(
        state.copyWith(
          medications: medications,
          medicationInput: const MedicalInfo.pure(),
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onRemoveMedication(RemoveMedication event, Emitter<MedicalIdState> emit) async {
    try {
      List<dynamic> medications = state.medications!;
      medications.removeAt(event.index);
      await _authenticationRepository.updateMedications(medications);
      emit(
        state.copyWith(
          medications: medications,
          formStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }
}
