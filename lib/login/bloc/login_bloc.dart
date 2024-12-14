import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:timer_count_down/timer_controller.dart';

part 'login_state.dart';
part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
            LoginState(timerController: CountdownController(autoStart: true))) {
    on<ResetLoginStatus>(_onResetLoginStatus);
    on<ResetFormStatus>(_onResetFormStatus);
    on<PhoneChanged>(_onPhoneChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<SmsCodeChanged>(_onSmsCodeChanged);
    on<LoginFormSubmitted>(_onLoginFormSubmitted);
    on<SmsCodeSubmitted>(_onSmsCodeSubmitted);
    on<ResendSmsCode>(_onResendSmsCode);
    on<ResendTimerDone>(_onResendTimerDone);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onResetLoginStatus(ResetLoginStatus event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      status: LoginStatus.initial,
      formStatus: FormzSubmissionStatus.initial,
      isValid: Formz.validate([
        state.phone,
      ]),
    ));
  }

  void _onResetFormStatus(ResetFormStatus event, Emitter<LoginState> emit) {
    emit(state.copyWith(formStatus: FormzSubmissionStatus.initial));
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<LoginState> emit) {
    final phone = Phone.dirty(event.phone);
    emit(
      state.copyWith(
        phone: phone,
        isValid: Formz.validate([
          phone,
        ]),
      ),
    );
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
      ),
    );
  }

  void _onSmsCodeChanged(SmsCodeChanged event, Emitter<LoginState> emit) {
    final smsCode = SmsCode.dirty(event.smsCode);
    emit(
      state.copyWith(
        smsCode: smsCode,
        isValid: Formz.validate([smsCode]),
      ),
    );
  }

  void _onResendSmsCode(ResendSmsCode event, Emitter<LoginState> emit) {
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

  void _onResendTimerDone(ResendTimerDone event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(resendReady: true),
    );
  }

  Future<void> _onLoginFormSubmitted(
      LoginFormSubmitted event, Emitter<LoginState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.loginVerification(
          phone: state.phone.value, password: state.password.value);
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        status: LoginStatus.phoneVerification,
        isValid: Formz.validate([state.smsCode]),
        resendReady: false
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

  Future<void> _onSmsCodeSubmitted(
      SmsCodeSubmitted event, Emitter<LoginState> emit) async {
    try {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
      await _authenticationRepository.login(
        phone: state.phone.value,
        smsCode: state.smsCode.value,
      );
      emit(state.copyWith(
          formStatus: FormzSubmissionStatus.success,
          status: LoginStatus.success));
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
