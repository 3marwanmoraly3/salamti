part of 'pastActivities_bloc.dart';

final class PastActivitiesState extends Equatable {
  const PastActivitiesState({
    this.loading = true,
    this.errorMessage,
    required this.pastActivities,
  });

  final bool loading;
  final String? errorMessage;
  final List<dynamic> pastActivities;

  @override
  List<Object?> get props => [
        loading,
        errorMessage,
        pastActivities,
      ];

  PastActivitiesState copyWith({
    bool? loading,
    String? errorMessage,
    required List<dynamic> pastActivities,
  }) {
    return PastActivitiesState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      pastActivities: pastActivities,
    );
  }
}
