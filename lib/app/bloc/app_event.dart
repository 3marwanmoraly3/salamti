part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

class _AppAuthenticationUserChanged extends AppEvent {
  const _AppAuthenticationUserChanged(
      {required this.userId});

  final String userId;
}

final class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}
