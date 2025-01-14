part of 'saveLocation_bloc.dart';

sealed class SaveLocationEvent {
  const SaveLocationEvent();
}

final class StatusChanged extends SaveLocationEvent {
  final SaveLocationStatus status;
  const StatusChanged(this.status);
}

final class CoordinatesChanged extends SaveLocationEvent {
  final double longitude;
  final double latitude;
  const CoordinatesChanged(this.longitude, this.latitude);
}

final class SearchChanged extends SaveLocationEvent {
  final String search;
  const SearchChanged(this.search);
}

final class SearchPlaceId extends SaveLocationEvent {
  final String placeId;
  const SearchPlaceId(this.placeId);
}

final class LocationNameChanged extends SaveLocationEvent {
  final String locationName;
  const LocationNameChanged(this.locationName);
}

final class SaveLocationSubmitted extends SaveLocationEvent {
  const SaveLocationSubmitted();
}