part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class InitialCheck extends HomeEvent {
  const InitialCheck();
}

final class RefreshSavedLocations extends HomeEvent {
  const RefreshSavedLocations();
}

final class DeleteSavedLocation extends HomeEvent {
  const DeleteSavedLocation(this.locationName);
  final String locationName;
}