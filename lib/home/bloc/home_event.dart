part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class InitialCheck extends HomeEvent {
  const InitialCheck();
}