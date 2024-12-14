part of 'requestEmergency_bloc.dart';

sealed class RequestEmergencyEvent {
  const RequestEmergencyEvent();
}

final class EmergencyRequested extends RequestEmergencyEvent {
  const EmergencyRequested();
}

final class StatusChanged extends RequestEmergencyEvent {
  final RequestEmergencyStatus status;

  const StatusChanged(this.status);
}

final class CoordinatesChanged extends RequestEmergencyEvent {
  final double longitude;
  final double latitude;

  const CoordinatesChanged(this.longitude, this.latitude);
}

final class SearchChanged extends RequestEmergencyEvent {
  final String search;

  const SearchChanged(this.search);
}

final class SearchPlaceId extends RequestEmergencyEvent {
  final String placeId;

  const SearchPlaceId(this.placeId);
}

final class EmergencyTypeChanged extends RequestEmergencyEvent {
  final String type;

  const EmergencyTypeChanged(this.type);
}
