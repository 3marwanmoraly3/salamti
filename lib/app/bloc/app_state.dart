part of 'app_bloc.dart';

enum AppStatus {
  initial,
  authenticated,
  unauthenticated,
}

final class AppState extends Equatable {
  const AppState._(
      {required this.status, this.userId = "", this.civilianId = ""});

  const AppState.initial() : this._(status: AppStatus.initial);

  const AppState.authenticated(
      {required String userId, required String civilianId})
      : this._(
            status: AppStatus.authenticated,
            userId: userId,
            civilianId: civilianId);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final String userId;
  final String civilianId;

  @override
  List<Object> get props => [status, userId, civilianId];
}
