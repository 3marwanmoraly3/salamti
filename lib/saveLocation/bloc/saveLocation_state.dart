part of 'saveLocation_bloc.dart';

enum SaveLocationStatus {
  pickLocation,
  nameLocation,
  success
}

final class SaveLocationState extends Equatable {
  const SaveLocationState({
    this.longitude = 35.876200,
    this.latitude = 32.023150,
    this.status = SaveLocationStatus.pickLocation,
    this.loading = false,
    this.autoCompleteList,
    this.locationName = const LocationName.pure(),
    this.isValid = false,
    this.formStatus = FormzSubmissionStatus.initial,
  });

  final double? longitude;
  final double? latitude;
  final SaveLocationStatus status;
  final bool loading;
  final List<dynamic>? autoCompleteList;
  final LocationName locationName;
  final bool isValid;
  final FormzSubmissionStatus formStatus;

  @override
  List<Object?> get props => [
    longitude,
    latitude,
    status,
    loading,
    autoCompleteList,
    locationName,
    isValid,
    formStatus,
  ];

  SaveLocationState copyWith({
    double? longitude,
    double? latitude,
    SaveLocationStatus? status,
    bool? loading,
    List<dynamic>? autoCompleteList,
    LocationName? locationName,
    bool? isValid,
    FormzSubmissionStatus? formStatus,
  }) {
    return SaveLocationState(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      status: status ?? this.status,
      loading: loading ?? this.loading,
      autoCompleteList: autoCompleteList ?? this.autoCompleteList,
      locationName: locationName ?? this.locationName,
      isValid: isValid ?? this.isValid,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}