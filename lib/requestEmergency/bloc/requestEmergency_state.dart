part of 'requestEmergency_bloc.dart';

enum RequestEmergencyStatus {
  pickLocation,
  emergencyType,
}

final class RequestEmergencyState extends Equatable {
  const RequestEmergencyState({
    this.longitude = 35.876200,
    this.latitude = 32.023150,
    this.status = RequestEmergencyStatus.pickLocation,
    this.loading = false,
    this.autoCompleteList,
    this.emergencyType,
    this.initialDispatch,
    this.errorMessage,
  });

  final double? longitude;
  final double? latitude;
  final RequestEmergencyStatus status;
  final bool? loading;
  final List<dynamic>? autoCompleteList;
  final String? emergencyType;
  final Map<String, int>? initialDispatch;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        longitude,
        latitude,
        status,
        loading,
        autoCompleteList,
        emergencyType,
    initialDispatch,
        errorMessage,
      ];

  RequestEmergencyState copyWith({
    double? longitude,
    double? latitude,
    RequestEmergencyStatus? status,
    bool? loading,
    List<dynamic>? autoCompleteList,
    String? emergencyType,
    Map<String, int>? initialDispatch,
    String? errorMessage,
  }) {
    return RequestEmergencyState(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      status: status ?? this.status,
      loading: loading ?? this.loading,
      autoCompleteList: autoCompleteList ?? this.autoCompleteList,
      emergencyType: emergencyType ?? this.emergencyType,
      initialDispatch: initialDispatch ?? this.initialDispatch,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

Map<String, Map<String, dynamic>> initialDispatchMap = {
  "medical": {
    "initialDispatch": {"ambulance": 1},
  },
  "carCrash": {
    "initialDispatch": {"police": 1},
  },
  "fire": {
    "initialDispatch": {"firetruck": 2},
  },
  "pedestrianCollision": {
    "initialDispatch": {"police": 1, "ambulance": 1},
  },
  "armedThreat": {
    "initialDispatch": {"police": 2},
  },
  "naturalDisaster": {
    "initialDispatch": {"police": 1, "firetruck": 1, "ambulance": 1},
  },
  "suicideAttempt": {
    "initialDispatch": {"police": 1},
  },
  "abduction": {
    "initialDispatch": {"police": 2},
  },
  "burglary": {
    "initialDispatch": {"police": 1},
  },
  "assault": {
    "initialDispatch": {"police": 1},
  },
  "domesticViolence": {
    "initialDispatch": {"police": 1},
  },
  "trapped": {
    "initialDispatch": {"firetruck": 1},
  }
};