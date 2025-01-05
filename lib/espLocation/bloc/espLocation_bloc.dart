import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_repository/google_maps_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:equatable/equatable.dart';

part 'espLocation_state.dart';
part 'espLocation_event.dart';

class EspLocationBloc extends Bloc<EspLocationEvent, EspLocationState> {
  final GoogleMapsRepository googleMapsRepository;
  final AuthenticationRepository authenticationRepository;
  StreamSubscription<List<Map<String, dynamic>>>? _locationSubscription;

  EspLocationBloc({
    required this.googleMapsRepository,
    required this.authenticationRepository,
  }) : super(const EspLocationState()) {
    on<StartTrackingEsps>(_onStartTrackingEsps);
    on<UpdateEspLocations>(_onUpdateEspLocations);
  }

  Future<void> _onStartTrackingEsps(
      StartTrackingEsps event,
      Emitter<EspLocationState> emit,
      ) async {
    try {
      if (event.espIds.isEmpty) {
        return;
      }

      emit(state.copyWith(
        isLoading: true,
        destination: event.destination,
        caseId: event.caseId,
      ));

      // Cancel existing subscription if any
      if (_locationSubscription != null) {
        await _locationSubscription!.cancel();
        _locationSubscription = null;
      }

      // Now set up the stream
      _locationSubscription = authenticationRepository
          .streamEspLocations(event.espIds, event.caseId)
          .listen(
            (espUpdates) async {
          try {
            final locations = <String, LatLng>{};
            final routes = <String, List<LatLng>>{};
            final arrivedStatus = <String, bool>{};
            final estimatedTimes = <String, double>{};
            final types = <String, String>{};

            for (final esp in espUpdates) {
              final location = esp['location'] as GeoPoint;
              final espId = esp['id'] as String;
              final currentLocation = LatLng(location.latitude, location.longitude);

              locations[espId] = currentLocation;
              types[espId] = esp['type'];
              arrivedStatus[espId] = esp['arrived'];

              if (!esp['arrived']) {
                try {
                  final route = await googleMapsRepository.getRouteToDestination(
                    origin: currentLocation,
                    destination: event.destination,
                  );

                  routes[espId] = route;
                  final estimatedTime = googleMapsRepository.calculateArrivalTime(route);
                  estimatedTimes[espId] = estimatedTime;
                } catch (routeError) {
                  // Don't add a route for this ESP if we couldn't get one
                  continue;
                }
              }
            }

            add(UpdateEspLocations(
              espLocations: locations,
              routes: routes,
              arrivedStatus: arrivedStatus,
              estimatedArrivalTimes: estimatedTimes,
              espTypes: types,
            ));
          } catch (e) {
            print('Error processing ESP updates: $e');
            emit(state.copyWith(error: 'Error processing ESP updates: $e'));
          }
        },
        onError: (error) {
          print('Stream error: $error');
          emit(state.copyWith(
            error: 'Error tracking ESPs: $error',
            isLoading: false,
          ));
        },
      );

      print('Stream subscription set up complete');

    } catch (e, stackTrace) {
      print('Error in _onStartTrackingEsps: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
        error: 'Failed to start ESP tracking: $e',
        isLoading: false,
      ));
    }
  }

  void _onUpdateEspLocations(
      UpdateEspLocations event,
      Emitter<EspLocationState> emit,
      ) {
    emit(state.copyWith(
      espLocations: event.espLocations,
      routes: event.routes,
      arrivedStatus: event.arrivedStatus,
      estimatedArrivalTimes: event.estimatedArrivalTimes,
      espTypes: event.espTypes,
      isLoading: false,
    ));
    if (event.arrivedStatus.isNotEmpty &&
        event.arrivedStatus.values.every((arrived) => arrived)) {
      emit(state.copyWith(
        isDone: true
      ));
    }
  }

  @override
  Future<void> close() async {
    if (_locationSubscription != null) {
      await _locationSubscription!.cancel();
    }
    return super.close();
  }
}