part of 'emergencyWaiting_bloc.dart';

sealed class EmergencyWaitingEvent {
  const EmergencyWaitingEvent();
}

final class InitialCheck extends EmergencyWaitingEvent {
  const InitialCheck();
}

final class StatusChanged extends EmergencyWaitingEvent {
  final EmergencyWaitingStatus status;

  const StatusChanged(this.status);
}

final class UpdateAnswer extends EmergencyWaitingEvent {
  final int index;
  final dynamic answer;

  const UpdateAnswer({
    required this.index,
    required this.answer,
  });

  List<Object?> get props => [index, answer];
}

final class SubmitAdditionalRequest extends EmergencyWaitingEvent {
  const SubmitAdditionalRequest();
}