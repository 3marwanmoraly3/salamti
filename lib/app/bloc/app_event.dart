part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

class _AppAuthenticationUserChanged extends AppEvent {
  const _AppAuthenticationUserChanged(
      {required this.userId, required this.civilianId});

  final String userId;
  final String civilianId;
}

final class AppInEmergency extends AppEvent {
  const AppInEmergency();
}

final class EmergencyDone extends AppEvent {
  const EmergencyDone();
}

final class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}
