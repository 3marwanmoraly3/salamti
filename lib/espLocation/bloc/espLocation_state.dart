part of 'espLocation_bloc.dart';

class EspLocationState extends Equatable {
  final Map<String, LatLng> espLocations;
  final Map<String, List<LatLng>> routes;
  final Map<String, bool> arrivedStatus;
  final Map<String, double> estimatedArrivalTimes;
  final Map<String, String> espTypes;
  final bool isLoading;
  final String? error;
  final LatLng? destination;
  final String? caseId;
  final bool? isDone;

  const EspLocationState({
    this.espLocations = const {},
    this.routes = const {},
    this.arrivedStatus = const {},
    this.estimatedArrivalTimes = const {},
    this.espTypes = const {},
    this.isLoading = false,
    this.error,
    this.destination,
    this.caseId,
    this.isDone = false,
  });

  EspLocationState copyWith({
    Map<String, LatLng>? espLocations,
    Map<String, List<LatLng>>? routes,
    Map<String, bool>? arrivedStatus,
    Map<String, double>? estimatedArrivalTimes,
    Map<String, String>? espTypes,
    bool? isLoading,
    String? error,
    LatLng? destination,
    String? caseId,
    bool? isDone,
  }) {
    return EspLocationState(
      espLocations: espLocations ?? this.espLocations,
      routes: routes ?? this.routes,
      arrivedStatus: arrivedStatus ?? this.arrivedStatus,
      estimatedArrivalTimes: estimatedArrivalTimes ?? this.estimatedArrivalTimes,
      espTypes: espTypes ?? this.espTypes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      destination: destination ?? this.destination,
      caseId: caseId ?? this.caseId,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  List<Object?> get props => [
    espLocations,
    routes,
    arrivedStatus,
    estimatedArrivalTimes,
    espTypes,
    isLoading,
    error,
    destination,
    caseId,
    isDone
  ];
}