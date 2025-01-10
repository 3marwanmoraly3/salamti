import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'pastActivities_state.dart';
part 'pastActivities_event.dart';

class PastActivitiesBloc
    extends Bloc<PastActivitiesEvent, PastActivitiesState> {
  PastActivitiesBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(const PastActivitiesState(pastActivities: [])) {
    on<InitialCheck>(_onInitialCheck);
    add(const InitialCheck());
  }

  final AuthenticationRepository _authenticationRepository;

  void _onInitialCheck(InitialCheck event,
      Emitter<PastActivitiesState> emit) async {
    List<dynamic> pastActivities =
        await _authenticationRepository.getPastActivities();
    emit(state.copyWith(pastActivities: pastActivities, loading: false));
  }
}
