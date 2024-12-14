part of 'login_bloc.dart';

sealed class LoginEvent {
  const LoginEvent();
}

final class ResetLoginStatus extends LoginEvent {
  const ResetLoginStatus();
}

final class ResetFormStatus extends LoginEvent {
  const ResetFormStatus();
}

final class PhoneChanged extends LoginEvent {
  final String phone;

  const PhoneChanged(this.phone);
}

final class PasswordChanged extends LoginEvent {
  final String password;

  const PasswordChanged(this.password);
}

final class SmsCodeChanged extends LoginEvent {
  final String smsCode;

  const SmsCodeChanged(this.smsCode);
}

final class LoginFormSubmitted extends LoginEvent {
  const LoginFormSubmitted();
}

final class SmsCodeSubmitted extends LoginEvent {
  const SmsCodeSubmitted();
}

final class ResendSmsCode extends LoginEvent {
  const ResendSmsCode();
}

final class ResendTimerDone extends LoginEvent {
  const ResendTimerDone();
}