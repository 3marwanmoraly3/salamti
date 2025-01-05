part of 'espLocation_bloc.dart';

sealed class EspLocationEvent extends Equatable {
  const EspLocationEvent();

  @override
  List<Object?> get props => [];
}

final class StartTrackingEsps extends EspLocationEvent {
  final List<String> espIds;
  final LatLng destination;
  final String caseId;

  const StartTrackingEsps({
    required this.espIds,
    required this.destination,
    required this.caseId,
  });

  @override
  List<Object?> get props => [espIds, destination, caseId];
}

final class UpdateEspLocations extends EspLocationEvent {
  final Map<String, LatLng> espLocations;
  final Map<String, List<LatLng>> routes;
  final Map<String, bool> arrivedStatus;
  final Map<String, double> estimatedArrivalTimes;
  final Map<String, String> espTypes;

  const UpdateEspLocations({
    required this.espLocations,
    required this.routes,
    required this.arrivedStatus,
    required this.estimatedArrivalTimes,
    required this.espTypes,
  });

  @override
  List<Object?> get props => [
    espLocations,
    routes,
    arrivedStatus,
    estimatedArrivalTimes,
    espTypes
  ];
}