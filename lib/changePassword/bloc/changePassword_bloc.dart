import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:timer_count_down/timer_controller.dart';

part 'changePassword_state.dart';
part 'changePassword_event.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(ChangePasswordState(timerController: CountdownController(autoStart: true))) {
    on<ResetChangePasswordStatus>(_onResetChangePasswordStatus);
    on<ResetFormStatus>(_onResetFormStatus);
    on<PhoneChanged>(_onPhoneChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmedPasswordChanged>(_onConfirmedPasswordChanged);
    on<SmsCodeChanged>(_onSmsCodeChanged);
    on<PhoneFormSubmitted>(_onPhoneFormSubmitted);
    on<SmsCodeSubmitted>(_onSmsCodeSubmitted);
    on<ChangePasswordFormSubmitted>(_onChangePasswordFormSubmitted);
    on<ResendSmsCode>(_onResendSmsCode);
    on<ResendTimerDone>(_onResendTimerDone);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onResetChangePasswordStatus(
      ResetChangePasswordStatus event, Emitter<ChangePasswordState> emit) {
    emit(state.copyWith(
      status: ChangePasswordStatus.initial,
      formStatus: FormzSubmissionStatus.initial,
      isValid: Formz.validate([
        state.phone,
      ]),
      resendReady: false,
    ));
  }

  void _onResetFormStatus(
      ResetFormStatus event, Emitter<ChangePasswordState> emit) {
    emit(state.copyWith(formStatus: FormzSubmissionStatus.initial));
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<ChangePasswordState> emit) {
    final phone = Phone.dirty(event.phone);
    emit(
      state.copyWith(
        phone: phone,
        isValid: Formz.validate([
          phone,
        ]),
        resendReady: false,
      ),
    );
  }

  void _onPasswordChanged(
      PasswordChanged event, Emitter<ChangePasswordState> emit) {
    final password = Password.dirty(event.password);
    final confirmedPassword = ConfirmedPassword.dirty(
      password: password.value,
      value: state.confirmedPassword.value,
    );
    emit(
      state.copyWith(
        password: password,
        confirmedPassword: confirmedPassword,
        isValid: Formz.validate([password, confirmedPassword]),
      ),
    );
  }

  void _onConfirmedPasswordChanged(
      ConfirmedPasswordChanged event, Emitter<ChangePasswordState> emit) {
    final confirmedPassword = ConfirmedPassword.dirty(
      password: state.password.value,
      value: event.confirmedPassword,
    );
    emit(
      state.copyWith(
        confirmedPassword: confirmedPassword,
        isValid: Formz.validate([state.password, confirmedPassword]),
      ),
    );
  }

  void _onSmsCodeChanged(
      SmsCodeChanged event, Emitter<ChangePasswordState> emit) {
    final smsCode = SmsCode.dirty(event.smsCode);
    emit(
      state.copyWith(
        smsCode: smsCode,
        isValid: Formz.validate([smsCode]),
      ),
    );
  }

  Future<void> _onPhoneFormSubmitted(
      PhoneFormSubmitted event, Emitter<ChangePasswordState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.changePasswordVerification(
        phone: state.phone.value,
      );
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        status: ChangePasswordStatus.phoneVerification,
        isValid: Formz.validate([state.smsCode]),
      ));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onResendSmsCode(ResendSmsCode event, Emitter<ChangePasswordState> emit) {
    try {
      _authenticationRepository.sendPhoneNumber(
        phone: state.phone.value,
      );
      emit(state.copyWith(resendReady: false));
      state.timerController!.restart();
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  void _onResendTimerDone(ResendTimerDone event, Emitter<ChangePasswordState> emit) {
    emit(
      state.copyWith(resendReady: true),
    );
  }

  Future<void> _onSmsCodeSubmitted(
      SmsCodeSubmitted event, Emitter<ChangePasswordState> emit) async {
    try {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
      _authenticationRepository.checkSmsCode(
        smsCode: state.smsCode.value,
      );
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        status: ChangePasswordStatus.changePassword,
        isValid: Formz.validate([state.password, state.confirmedPassword]),
      ));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  Future<void> _onChangePasswordFormSubmitted(ChangePasswordFormSubmitted event,
      Emitter<ChangePasswordState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.changePassword(
        phone: state.phone.value,
        password: state.password.value,
      );
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.success,
        status: ChangePasswordStatus.success,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          formStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }
}
