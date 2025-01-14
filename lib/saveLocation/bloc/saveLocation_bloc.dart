import 'package:google_maps_repository/google_maps_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';

part 'saveLocation_state.dart';
part 'saveLocation_event.dart';

class SaveLocationBloc extends Bloc<SaveLocationEvent, SaveLocationState> {
  SaveLocationBloc({
    required GoogleMapsRepository googleMapsRepository,
    required AuthenticationRepository authenticationRepository,
  })  : _googleMapsRepository = googleMapsRepository,
        _authenticationRepository = authenticationRepository,
        super(const SaveLocationState(autoCompleteList: [])) {
    on<StatusChanged>(_onStatusChanged);
    on<CoordinatesChanged>(_onCoordinatesChanged);
    on<SearchChanged>(_onSearchChanged);
    on<SearchPlaceId>(_onSearchPlaceId);
    on<LocationNameChanged>(_onLocationNameChanged);
    on<SaveLocationSubmitted>(_onSaveLocationSubmitted);
  }

  final GoogleMapsRepository _googleMapsRepository;
  final AuthenticationRepository _authenticationRepository;

  void _onStatusChanged(
      StatusChanged event,
      Emitter<SaveLocationState> emit,
      ) {
    emit(state.copyWith(status: event.status));
  }

  void _onCoordinatesChanged(
      CoordinatesChanged event,
      Emitter<SaveLocationState> emit,
      ) {
    final longitude = event.longitude;
    final latitude = event.latitude;
    emit(state.copyWith(longitude: longitude, latitude: latitude));
  }

  void _onSearchChanged(
      SearchChanged event,
      Emitter<SaveLocationState> emit,
      ) async {
    final search = event.search;
    emit(state.copyWith(loading: true));
    List<dynamic> autoCompleteList =
    await _googleMapsRepository.getLocationAutoComplete(
      search,
      state.longitude.toString(),
      state.latitude.toString(),
    );
    emit(state.copyWith(autoCompleteList: autoCompleteList, loading: false));
  }

  void _onSearchPlaceId(
      SearchPlaceId event,
      Emitter<SaveLocationState> emit,
      ) async {
    final placeId = event.placeId;
    Map<String, double> locationDetails =
    await _googleMapsRepository.getLocationFromPlaceId(placeId);
    emit(state.copyWith(
      latitude: locationDetails["latitude"],
      longitude: locationDetails["longitude"],
    ));
  }

  void _onLocationNameChanged(
      LocationNameChanged event,
      Emitter<SaveLocationState> emit,
      ) {
    final locationName = LocationName.dirty(event.locationName);
    emit(state.copyWith(
      locationName: locationName,
      isValid: Formz.validate([locationName]),
    ));
  }

  void _onSaveLocationSubmitted(
      SaveLocationSubmitted event,
      Emitter<SaveLocationState> emit,
      ) async {
    if (!state.isValid) return;
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.saveLocation(
        name: state.locationName.value,
        latitude: state.latitude!,
        longitude: state.longitude!,
      );
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.success,
        status: SaveLocationStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }
  }
}