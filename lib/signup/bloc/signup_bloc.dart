import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:timer_count_down/timer_controller.dart';

part 'signup_state.dart';
part 'signup_event.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(SignUpState(
            timerController: CountdownController(autoStart: true))) {
    on<ResetSignUpStatus>(_onResetSignUpStatus);
    on<ResetFormStatus>(_onResetFormStatus);
    on<NameChanged>(_onNameChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmedPasswordChanged>(_onConfirmedPasswordChanged);
    on<SmsCodeChanged>(_onSmsCodeChanged);
    on<SignUpFormSubmitted>(_onSignUpFormSubmitted);
    on<SmsCodeSubmitted>(_onSmsCodeSubmitted);
    on<ResendSmsCode>(_onResendSmsCode);
    on<ResendTimerDone>(_onResendTimerDone);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onResetSignUpStatus(
      ResetSignUpStatus event, Emitter<SignUpState> emit) {
    emit(state.copyWith(
        status: SignUpStatus.initial,
        formStatus: FormzSubmissionStatus.initial,
        isValid: Formz.validate(
            [state.name, state.phone, state.password, state.confirmedPassword]),
        resendReady: false));
  }

  void _onResetFormStatus(ResetFormStatus event, Emitter<SignUpState> emit) {
    emit(state.copyWith(formStatus: FormzSubmissionStatus.initial));
  }

  void _onNameChanged(NameChanged event, Emitter<SignUpState> emit) {
    final name = Name.dirty(event.name);
    emit(
      state.copyWith(
        name: name,
        isValid: Formz.validate(
            [name, state.phone, state.password, state.confirmedPassword]),
      ),
    );
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<SignUpState> emit) {
    final phone = Phone.dirty(event.phone);
    emit(
      state.copyWith(
        phone: phone,
        isValid: Formz.validate(
            [state.name, phone, state.password, state.confirmedPassword]),
      ),
    );
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<SignUpState> emit) {
    final password = Password.dirty(event.password);
    final confirmedPassword = ConfirmedPassword.dirty(
      password: password.value,
      value: state.confirmedPassword.value,
    );
    emit(
      state.copyWith(
        password: password,
        confirmedPassword: confirmedPassword,
        isValid: Formz.validate(
            [state.name, state.phone, password, confirmedPassword]),
      ),
    );
  }

  void _onConfirmedPasswordChanged(
      ConfirmedPasswordChanged event, Emitter<SignUpState> emit) {
    final confirmedPassword = ConfirmedPassword.dirty(
      password: state.password.value,
      value: event.confirmedPassword,
    );
    emit(
      state.copyWith(
        confirmedPassword: confirmedPassword,
        isValid: Formz.validate(
            [state.name, state.phone, state.password, confirmedPassword]),
      ),
    );
  }

  void _onSmsCodeChanged(SmsCodeChanged event, Emitter<SignUpState> emit) {
    final smsCode = SmsCode.dirty(event.smsCode);
    emit(
      state.copyWith(
        smsCode: smsCode,
        isValid: Formz.validate([smsCode]),
      ),
    );
  }

  void _onResendSmsCode(ResendSmsCode event, Emitter<SignUpState> emit) {
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

  void _onResendTimerDone(ResendTimerDone event, Emitter<SignUpState> emit) {
    emit(
      state.copyWith(resendReady: true),
    );
  }

  Future<void> _onSignUpFormSubmitted(
      SignUpFormSubmitted event, Emitter<SignUpState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    try {
      await _authenticationRepository.signUpVerification(
        phone: state.phone.value,
      );
      emit(state.copyWith(
        formStatus: FormzSubmissionStatus.initial,
        status: SignUpStatus.phoneVerification,
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

  Future<void> _onSmsCodeSubmitted(
      SmsCodeSubmitted event, Emitter<SignUpState> emit) async {
    try {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
      await _authenticationRepository.signUp(
        name: state.name.value,
        phone: state.phone.value,
        password: state.password.value,
        smsCode: state.smsCode.value,
      );
      emit(state.copyWith(
          formStatus: FormzSubmissionStatus.success,
          status: SignUpStatus.success));
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
