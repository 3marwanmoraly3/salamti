part of 'app_bloc.dart';

enum AppStatus {
  initial,
  authenticated,
  unauthenticated,
  emergency,
}

final class AppState extends Equatable {
  const AppState._(
      {required this.status, this.userId = "", this.civilianId = "", this.emergencyWaitingStatus = ""});

  const AppState.initial() : this._(status: AppStatus.initial);

  const AppState.authenticated(
      {required String userId, required String civilianId})
      : this._(
            status: AppStatus.authenticated,
            userId: userId,
            civilianId: civilianId);

  const AppState.emergency({
    required String userId,
    required String civilianId,
    required String emergencyWaitingStatus,
  }) : this._(
      status: AppStatus.emergency,
      userId: userId,
      civilianId: civilianId,
      emergencyWaitingStatus: emergencyWaitingStatus
  );

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final String userId;
  final String civilianId;
  final String emergencyWaitingStatus;

  @override
  List<Object> get props => [status, userId, civilianId, emergencyWaitingStatus];
}
