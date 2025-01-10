part of 'pastActivities_bloc.dart';

sealed class PastActivitiesEvent {
  const PastActivitiesEvent();
}

final class InitialCheck extends PastActivitiesEvent {
  const InitialCheck();
}
