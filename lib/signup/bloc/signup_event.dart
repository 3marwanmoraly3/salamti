part of 'signup_bloc.dart';

sealed class SignUpEvent {
  const SignUpEvent();
}

final class ResetSignUpStatus extends SignUpEvent {
  const ResetSignUpStatus();
}

final class ResetFormStatus extends SignUpEvent {
  const ResetFormStatus();
}

final class NameChanged extends SignUpEvent {
  final String name;

  const NameChanged(this.name);
}

final class PhoneChanged extends SignUpEvent {
  final String phone;

  const PhoneChanged(this.phone);
}

final class PasswordChanged extends SignUpEvent {
  final String password;

  const PasswordChanged(this.password);
}

final class ConfirmedPasswordChanged extends SignUpEvent {
  final String confirmedPassword;

  const ConfirmedPasswordChanged(this.confirmedPassword);
}

final class SmsCodeChanged extends SignUpEvent {
  final String smsCode;

  const SmsCodeChanged(this.smsCode);
}

final class SignUpFormSubmitted extends SignUpEvent {
  const SignUpFormSubmitted();
}

final class SmsCodeSubmitted extends SignUpEvent {
  const SmsCodeSubmitted();
}

final class ResendSmsCode extends SignUpEvent {
  const ResendSmsCode();
}

final class ResendTimerDone extends SignUpEvent {
  const ResendTimerDone();
}