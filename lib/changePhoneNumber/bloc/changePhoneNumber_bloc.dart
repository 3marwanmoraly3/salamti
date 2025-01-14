import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:timer_count_down/timer_controller.dart';

part 'changePhoneNumber_state.dart';
part 'changePhoneNumber_event.dart';

class ChangePhoneNumberBloc
    extends Bloc<ChangePhoneNumberEvent, ChangePhoneNumberState> {
  ChangePhoneNumberBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(ChangePhoneNumberState(timerController: CountdownController(autoStart: true))) {
    on<ResetChangePhoneNumberStatus>(_onResetChangePhoneNumberStatus);
    on<ResetFormStatus>(_onResetFormStatus);
    on<PhoneChanged>(_onPhoneChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<SmsCodeChanged>(_onSmsCodeChanged);
    on<PasswordFormSubmitted>(_onPasswordFormSubmitted);
    on<PhoneFormSubmitted>(_onPhoneFormSubmitted);
    on<SmsCodeSubmitted>(_onSmsCodeSubmitted);
    on<ResendSmsCode>(_onResendSmsCode);
    on<ResendTimerDone>(_onResendTimerDone);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onResetChangePhoneNumberStatus(
      ResetChangePhoneNumberStatus event, Emitter<ChangePhoneNumberState> emit) {
    emit(state.copyWith(
      status: ChangePhoneNumberStatus.initial,
      formStatus: FormzSubmissionStatus.initial,
      isValid: Formz.validate([
        state.phone,
      ]),
      resendReady: false,
    ));
  }

  void _onResetFormStatus(
      ResetFormStatus event, Emitter<ChangePhoneNumberState> emit) {
    emit(state.copyWith(formStatus: FormzSubmissionStatus.initial));
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<ChangePhoneNumberState> emit) {
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
      PasswordChanged event, Emitter<ChangePhoneNumberState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: password.value.isNotEmpty
      ),
    );
  }

  void _onSmsCodeChanged(
      SmsCodeChanged event, Emitter<ChangePhoneNumberState> emit) {
    final smsCode = SmsCode.dirty(event.smsCode);
    emit(
      state.copyWith(
        smsCode: smsCode,
        isValid: Formz.validate([smsCode]),
      ),
    );
  }

  Future<void> _onPasswordFormSubmitted(
      PasswordFormSubmitted event, Emitter<ChangePhoneNumberState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.checkPassword(
        password: state.password.value,
      );
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        status: ChangePhoneNumberStatus.changePhoneNumber,
        isValid: Formz.validate([state.phone]),
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

  Future<void> _onPhoneFormSubmitted(
      PhoneFormSubmitted event, Emitter<ChangePhoneNumberState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.changePhoneVerification(
        phone: state.phone.value,
      );
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        status: ChangePhoneNumberStatus.phoneVerification,
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

  void _onResendSmsCode(ResendSmsCode event, Emitter<ChangePhoneNumberState> emit) {
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

  void _onResendTimerDone(ResendTimerDone event, Emitter<ChangePhoneNumberState> emit) {
    emit(
      state.copyWith(resendReady: true),
    );
  }

  Future<void> _onSmsCodeSubmitted(
      SmsCodeSubmitted event, Emitter<ChangePhoneNumberState> emit) async {
    try {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
      _authenticationRepository.checkSmsCode(
        smsCode: state.smsCode.value,
      );
      await _authenticationRepository.changePhoneNumber(
        phone: state.phone.value,
      );
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.success,
        status: ChangePhoneNumberStatus.success,
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
