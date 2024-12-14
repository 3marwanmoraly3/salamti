part of 'login_bloc.dart';

enum LoginStatus {
  initial,
  phoneVerification,
  success
}

final class LoginState extends Equatable {
  const LoginState({
    this.phone = const Phone.pure(),
    this.password = const Password.pure(),
    this.smsCode = const SmsCode.pure(),
    this.status = LoginStatus.initial,
    this.formStatus = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.resendReady = false,
    this.timerController,
  });

  final Phone phone;
  final Password password;
  final SmsCode smsCode;
  final LoginStatus status;
  final FormzSubmissionStatus formStatus;
  final bool isValid;
  final String? errorMessage;
  final bool resendReady;
  final CountdownController? timerController;

  @override
  List<Object?> get props => [
    phone,
    password,
    smsCode,
    status,
    formStatus,
    isValid,
    errorMessage,
    resendReady,
    timerController
  ];

  LoginState copyWith({
    Phone? phone,
    Password? password,
    SmsCode? smsCode,
    LoginStatus? status,
    FormzSubmissionStatus? formStatus,
    bool? isValid,
    String? errorMessage,
    bool? resendReady,
    CountdownController? timerController
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      smsCode: smsCode ?? this.smsCode,
      status: status ?? this.status,
      formStatus: formStatus ?? this.formStatus,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      resendReady: resendReady ?? this.resendReady,
      timerController: timerController ?? this.timerController
    );
  }
}