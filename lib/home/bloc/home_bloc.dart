import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(const HomeState(savedLocations: [])) {
    on<InitialCheck>(_onInitialCheck);
    on<RefreshSavedLocations>(_onRefreshSavedLocations);
    on<DeleteSavedLocation>(_onDeleteSavedLocation);
    add(const InitialCheck());
  }

  final AuthenticationRepository _authenticationRepository;

  void _onInitialCheck(InitialCheck event, Emitter<HomeState> emit) async {
    List<dynamic> savedLocations = await _authenticationRepository.getSavedLocations();
    emit(state.copyWith(savedLocations: savedLocations, loading: false));
  }

  void _onRefreshSavedLocations(RefreshSavedLocations event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loading: true, savedLocations: state.savedLocations));
    List<dynamic> savedLocations = await _authenticationRepository.getSavedLocations();
    emit(state.copyWith(savedLocations: savedLocations, loading: false));
  }

  void _onDeleteSavedLocation(DeleteSavedLocation event, Emitter<HomeState> emit) async {
    try {
      await _authenticationRepository.deleteSavedLocation(event.locationName);
      List<dynamic> savedLocations = await _authenticationRepository.getSavedLocations();
      emit(state.copyWith(savedLocations: savedLocations));
    } catch (e) {
      print(e);
    }
  }
}
