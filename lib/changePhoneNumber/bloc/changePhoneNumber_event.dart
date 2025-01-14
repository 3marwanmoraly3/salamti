part of 'changePhoneNumber_bloc.dart';

sealed class ChangePhoneNumberEvent {
  const ChangePhoneNumberEvent();
}

final class ResetChangePhoneNumberStatus extends ChangePhoneNumberEvent {
  const ResetChangePhoneNumberStatus();
}

final class ResetFormStatus extends ChangePhoneNumberEvent {
  const ResetFormStatus();
}

final class PhoneChanged extends ChangePhoneNumberEvent {
  final String phone;

  const PhoneChanged(this.phone);
}

final class PasswordChanged extends ChangePhoneNumberEvent {
  final String password;

  const PasswordChanged(this.password);
}

final class SmsCodeChanged extends ChangePhoneNumberEvent {
  final String smsCode;

  const SmsCodeChanged(this.smsCode);
}

final class PasswordFormSubmitted extends ChangePhoneNumberEvent {
  const PasswordFormSubmitted();
}

final class PhoneFormSubmitted extends ChangePhoneNumberEvent {
  const PhoneFormSubmitted();
}

final class SmsCodeSubmitted extends ChangePhoneNumberEvent {
  const SmsCodeSubmitted();
}

final class ChangePhoneNumberFormSubmitted extends ChangePhoneNumberEvent {
  const ChangePhoneNumberFormSubmitted();
}

final class ResendSmsCode extends ChangePhoneNumberEvent {
  const ResendSmsCode();
}

final class ResendTimerDone extends ChangePhoneNumberEvent {
  const ResendTimerDone();
}

