part of 'signup_bloc.dart';

enum SignUpStatus { initial, phoneVerification, success }

final class SignUpState extends Equatable {
  const SignUpState({
    this.name = const Name.pure(),
    this.phone = const Phone.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.smsCode = const SmsCode.pure(),
    this.status = SignUpStatus.initial,
    this.formStatus = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
    this.resendReady = false,
    this.timerController,
  });

  final Name name;
  final Phone phone;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final SmsCode smsCode;
  final SignUpStatus status;
  final FormzSubmissionStatus formStatus;
  final bool isValid;
  final String? errorMessage;
  final bool resendReady;
  final CountdownController? timerController;

  @override
  List<Object?> get props => [
        name,
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

  SignUpState copyWith(
      {Name? name,
      Phone? phone,
      Password? password,
      ConfirmedPassword? confirmedPassword,
      SmsCode? smsCode,
      SignUpStatus? status,
      FormzSubmissionStatus? formStatus,
      bool? isValid,
      String? errorMessage,
      bool? resendReady,
      CountdownController? timerController}) {
    return SignUpState(
        name: name ?? this.name,
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
