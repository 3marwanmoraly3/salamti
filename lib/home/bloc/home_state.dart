part of 'home_bloc.dart';

final class HomeState extends Equatable {
  const HomeState({
    this.loading = true,
    this.errorMessage,
    required this.savedLocations,
  });

  final bool loading;
  final String? errorMessage;
  final List<dynamic> savedLocations;

  @override
  List<Object?> get props => [
        loading,
        errorMessage,
        savedLocations,
      ];

  HomeState copyWith({
    bool? loading,
    String? errorMessage,
    required List<dynamic> savedLocations,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      savedLocations: savedLocations,
    );
  }
}
