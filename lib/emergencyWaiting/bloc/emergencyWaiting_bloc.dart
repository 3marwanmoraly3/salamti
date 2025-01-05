import 'package:google_maps_repository/google_maps_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'emergencyWaiting_state.dart';
part 'emergencyWaiting_event.dart';

class EmergencyWaitingBloc
    extends Bloc<EmergencyWaitingEvent, EmergencyWaitingState> {
  EmergencyWaitingBloc(
      {required GoogleMapsRepository googleMapsRepository,
      required AuthenticationRepository authenticationRepository})
      : _googleMapsRepository = googleMapsRepository,
        _authenticationRepository = authenticationRepository,
        super(const EmergencyWaitingState()) {
    on<StatusChanged>(_onStatusChanged);
    on<UpdateAnswer>(_onUpdateAnswer);
    on<SubmitAdditionalRequest>(_onSubmitAdditionalRequest);
    on<InitialCheck>(_onInitialCheck);
    add(const InitialCheck());
  }

  final GoogleMapsRepository _googleMapsRepository;
  final AuthenticationRepository _authenticationRepository;

  void _onInitialCheck(
      InitialCheck event, Emitter<EmergencyWaitingState> emit) async {
    print('_onInitialCheck called');
    final emergencyWaitingDetails =
        await _authenticationRepository.getInitialEmergencyWaitingDetails();
    final espIds = emergencyWaitingDetails["espIds"];
    final emergencyType = emergencyWaitingDetails["emergencyType"];
    final longitude = emergencyWaitingDetails["longitude"];
    final latitude = emergencyWaitingDetails["latitude"];
    final caseId = emergencyWaitingDetails["caseId"];
    final questions = emergencyQuestions[emergencyType]?["questions"];
    final inEmergency =
        await _authenticationRepository.getEmergencyWaitingStatus();

    EmergencyWaitingStatus emergencyWaitingStatus;

    if (inEmergency == "survey") {
      emergencyWaitingStatus = EmergencyWaitingStatus.emergencyDetails;
    } else {
      emergencyWaitingStatus = EmergencyWaitingStatus.waiting;
    }

    emit(state.copyWith(
      espIds: espIds,
      emergencyType: emergencyType,
      longitude: longitude,
      latitude: latitude,
      status: emergencyWaitingStatus,
      questions: questions,
      originalQuestions: questions,
      caseId: caseId,
    ));
  }

  void _onUpdateAnswer(
    UpdateAnswer event,
    Emitter<EmergencyWaitingState> emit,
  ) {
    final currentAnswers = Map<int, dynamic>.from(state.answers);
    currentAnswers[event.index] = event.answer;

    if (state.questions![event.index].containsKey("boolMore")) {
      final subQuestions =
          state.questions![event.index]["boolMore"]["subQuestions"] as List;

      // Create new questions list from original questions
      final currentQuestions = List<dynamic>.from(state.originalQuestions!);

      if (event.answer == true) {
        // Insert subQuestions after the boolMore question
        currentQuestions.insertAll(event.index + 1, subQuestions);
      }

      emit(state.copyWith(
        questions: currentQuestions,
        answers: currentAnswers,
      ));
    } else {
      emit(state.copyWith(answers: currentAnswers));
    }
  }

  Future<void> _onSubmitAdditionalRequest(
    SubmitAdditionalRequest event,
    Emitter<EmergencyWaitingState> emit,
  ) async {
    try {
      emit(state.copyWith(loading: true, errorMessage: null));

      final espIds = await _authenticationRepository.requestAdditionalEmergency(
          questions: state.questions,
          answers: state.answers,
          longitude: state.longitude,
          latitude: state.latitude);

      emit(state.copyWith(
        loading: false,
        status: EmergencyWaitingStatus.waiting,
        espIds: espIds
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onStatusChanged(
      StatusChanged event, Emitter<EmergencyWaitingState> emit) {
    final status = event.status;
    emit(
      state.copyWith(status: status),
    );
  }
}
