import 'package:google_maps_repository/google_maps_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'requestEmergency_state.dart';

part 'requestEmergency_event.dart';

class RequestEmergencyBloc
    extends Bloc<RequestEmergencyEvent, RequestEmergencyState> {
  RequestEmergencyBloc(
      {required GoogleMapsRepository googleMapsRepository,
      required AuthenticationRepository authenticationRepository})
      : _googleMapsRepository = googleMapsRepository,
        _authenticationRepository = authenticationRepository,
        super(const RequestEmergencyState(autoCompleteList: [])) {
    on<EmergencyRequested>(_onEmergencyRequested);
    on<StatusChanged>(_onStatusChanged);
    on<CoordinatesChanged>(_onCoordinatesChanged);
    on<SearchChanged>(_onSearchChanged);
    on<SearchPlaceId>(_onSearchPlaceId);
    on<EmergencyTypeChanged>(_onEmergencyTypeChanged);
  }

  final GoogleMapsRepository _googleMapsRepository;
  final AuthenticationRepository _authenticationRepository;

  void _onEmergencyRequested(
      EmergencyRequested event, Emitter<RequestEmergencyState> emit) async {
    emit(
      state.copyWith(loading: true),
    );
    await _authenticationRepository.requestEmergency(
        emergencyType: state.emergencyType!,
        latitude: state.latitude!,
        longitude: state.longitude!,
        initialDispatch: initialDispatchMap[state.emergencyType!]
            ?["initialDispatch"]);
    emit(
      state.copyWith(
        status: RequestEmergencyStatus.success,
          loading: false),
    );
  }

  void _onStatusChanged(
      StatusChanged event, Emitter<RequestEmergencyState> emit) {
    final status = event.status;
    emit(
      state.copyWith(status: status),
    );
  }

  void _onCoordinatesChanged(
      CoordinatesChanged event, Emitter<RequestEmergencyState> emit) {
    final longitude = event.longitude;
    final latitude = event.latitude;
    emit(
      state.copyWith(longitude: longitude, latitude: latitude),
    );
  }

  void _onSearchChanged(
      SearchChanged event, Emitter<RequestEmergencyState> emit) async {
    final search = event.search;
    emit(
      state.copyWith(loading: true),
    );
    List<dynamic> autoCompleteList =
        await _googleMapsRepository.getLocationAutoComplete(
            search, state.longitude.toString(), state.latitude.toString());
    emit(
      state.copyWith(autoCompleteList: autoCompleteList, loading: false),
    );
  }

  void _onSearchPlaceId(
      SearchPlaceId event, Emitter<RequestEmergencyState> emit) async {
    final placeId = event.placeId;
    Map<String, double> locationDetails =
        await _googleMapsRepository.getLocationFromPlaceId(placeId);
    emit(
      state.copyWith(
          latitude: locationDetails["latitude"],
          longitude: locationDetails["longitude"]),
    );
  }

  void _onEmergencyTypeChanged(
      EmergencyTypeChanged event, Emitter<RequestEmergencyState> emit) {
    final type = event.type;
    emit(
      state.copyWith(emergencyType: type),
    );
  }
}
