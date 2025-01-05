import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(const AppState.initial()) {
    on<_AppAuthenticationUserChanged>(_onAppAuthenticationUserChanged);
    on<AppInEmergency>(_onAppInEmergency);
    on<EmergencyDone>(_onEmergencyDone);
    on<AppLogoutRequested>(_onLogoutRequested);
    _authenticationUserSubscription =
        _authenticationRepository.authenticationUser.listen(
      (userAndCivilianId) => add(_AppAuthenticationUserChanged(
          userId: userAndCivilianId["userId"]!,
          civilianId: userAndCivilianId["civilianId"]!)),
    );

    _checkInitialAuthenticationState();
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<Map<String, String>>
      _authenticationUserSubscription;

  Future<void> _checkInitialAuthenticationState() async {
    final userId = await _authenticationRepository.getUserId();
    final civilianId = await _authenticationRepository.getCivilianId();
    if (userId != null && civilianId != null) {
      add(_AppAuthenticationUserChanged(
          userId: userId, civilianId: civilianId));
    } else {
      add(const _AppAuthenticationUserChanged(userId: "", civilianId: ""));
    }
  }

  void _onAppAuthenticationUserChanged(
      _AppAuthenticationUserChanged event, Emitter<AppState> emit) async {
    String userId = event.userId;
    String username = event.civilianId;
    dynamic appState = const AppState.unauthenticated();
    if (userId.isNotEmpty) {
      final emergencyWaitingStatus =
          await _authenticationRepository.getEmergencyWaitingStatus();
      if (emergencyWaitingStatus == "no") {
        appState = AppState.authenticated(userId: userId, civilianId: username);
      } else {
        appState = AppState.emergency(
            userId: userId,
            civilianId: username,
            emergencyWaitingStatus: emergencyWaitingStatus);
      }
    }
    emit(appState);
  }

  void _onAppInEmergency(AppInEmergency event, Emitter<AppState> emit) async {
    final userId = state.userId;
    final civilianId = state.civilianId;

    emit(
      AppState.emergency(
          userId: userId,
          civilianId: civilianId,
          emergencyWaitingStatus: "survey"),
    );
  }

  void _onEmergencyDone(EmergencyDone event, Emitter<AppState> emit) async {
    final userId = await _authenticationRepository.getUserId();
    final civilianId = await _authenticationRepository.getCivilianId();

    emit(
      AppState.authenticated(
        userId: userId!,
        civilianId: civilianId!,
      ),
    );
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _authenticationUserSubscription.cancel();
    return super.close();
  }
}
