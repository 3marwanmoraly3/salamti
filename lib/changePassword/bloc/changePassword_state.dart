part of 'changePassword_bloc.dart';

enum ChangePasswordStatus {
  initial,
  phoneVerification,
  changePassword,
  success
}

final class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.phone = const Phone.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.smsCode = const SmsCode.pure(),
    this.status = ChangePasswordStatus.initial,
    this.formStatus = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.resendReady = false,
    this.timerController,
  });

  final Phone phone;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final SmsCode smsCode;
  final ChangePasswordStatus status;
  final FormzSubmissionStatus formStatus;
  final bool isValid;
  final String? errorMessage;
  final bool resendReady;
  final CountdownController? timerController;

  @override
  List<Object?> get props => [
        phone,
        password,
        confirmedPassword,
        smsCode,
        status,
        formStatus,
        isValid,
        errorMessage,
        resendReady,
        timerController
      ];

  ChangePasswordState copyWith(
      {Phone? phone,
      Password? password,
      ConfirmedPassword? confirmedPassword,
      SmsCode? smsCode,
      ChangePasswordStatus? status,
      FormzSubmissionStatus? formStatus,
      bool? isValid,
      String? errorMessage,
      bool? resendReady,
      CountdownController? timerController}) {
    return ChangePasswordState(
        phone: phone ?? this.phone,
        password: password ?? this.password,
        confirmedPassword: confirmedPassword ?? this.confirmedPassword,
        smsCode: smsCode ?? this.smsCode,
        status: status ?? this.status,
        formStatus: formStatus ?? this.formStatus,
        isValid: isValid ?? this.isValid,
        errorMessage: errorMessage ?? this.errorMessage,
        resendReady: resendReady ?? this.resendReady,
        timerController: timerController ?? this.timerController);
  }
}
