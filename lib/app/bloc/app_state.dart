part of 'app_bloc.dart';

enum AppStatus {
  initial,
  authenticated,
  unauthenticated,
}

final class AppState extends Equatable {
  const AppState._(
      {required this.status, this.userId = ""});

  const AppState.initial() : this._(status: AppStatus.initial);

  const AppState.authenticated(
      {required String userId})
      : this._(
            status: AppStatus.authenticated,
            userId: userId);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final String userId;

  @override
  List<Object> get props => [status, userId];
}
