import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc
    extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(const HomeState(savedLocations: [])) {
    on<InitialCheck>(_onInitialCheck);
    add(const InitialCheck());
  }

  final AuthenticationRepository _authenticationRepository;

  void _onInitialCheck(InitialCheck event,
      Emitter<HomeState> emit) async {
    List<dynamic> savedLocations =
        await _authenticationRepository.getSavedLocations();
    emit(state.copyWith(savedLocations: savedLocations, loading: false));
  }
}
