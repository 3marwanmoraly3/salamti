part of 'changePassword_bloc.dart';

sealed class ChangePasswordEvent {
  const ChangePasswordEvent();
}

final class ResetChangePasswordStatus extends ChangePasswordEvent {
  const ResetChangePasswordStatus();
}

final class ResetFormStatus extends ChangePasswordEvent {
  const ResetFormStatus();
}

final class PhoneChanged extends ChangePasswordEvent {
  final String phone;

  const PhoneChanged(this.phone);
}

final class PasswordChanged extends ChangePasswordEvent {
  final String password;

  const PasswordChanged(this.password);
}

final class ConfirmedPasswordChanged extends ChangePasswordEvent {
  final String confirmedPassword;

  const ConfirmedPasswordChanged(this.confirmedPassword);
}

final class SmsCodeChanged extends ChangePasswordEvent {
  final String smsCode;

  const SmsCodeChanged(this.smsCode);
}

final class PhoneFormSubmitted extends ChangePasswordEvent {
  const PhoneFormSubmitted();
}

final class SmsCodeSubmitted extends ChangePasswordEvent {
  const SmsCodeSubmitted();
}

final class ChangePasswordFormSubmitted extends ChangePasswordEvent {
  const ChangePasswordFormSubmitted();
}

final class ResendSmsCode extends ChangePasswordEvent {
  const ResendSmsCode();
}

final class ResendTimerDone extends ChangePasswordEvent {
  const ResendTimerDone();
}

