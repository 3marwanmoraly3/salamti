import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/login/login.dart';
import 'package:salamti/signup/signup.dart' show SignUpPage;
import 'package:salamti/changePassword/changePassword.dart'
    show ChangePasswordPage;
import 'package:formz/formz.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Login Failure')),
            );
          context.read<LoginBloc>().add(const ResetFormStatus());
        }
      },
      builder: (context, state) {
        if (state.status == LoginStatus.initial) {
          return _LoginInitial(
            phoneController: _phoneController,
            passwordController: _passwordController,
          );
        } else {
          return _LoginPhoneVerification();
        }
      },
    );
  }
}

class _LoginPhoneVerification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 60,
          ),
          onPressed: () {
            context.read<LoginBloc>().add(const ResetLoginStatus());
          },
          padding: EdgeInsets.zero,
        ),
      ),
      body: Align(
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Verification Code",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                  "We have sent the code to +962${context.read<LoginBloc>().state.phone.value}"),
              const SizedBox(height: 24),
              _SmsCodeInput(),
              _SmsCodeTimer(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ResendButton(),
                    _LoginButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmsCodeTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          previous.resendReady != current.resendReady,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Resend code after: "),
            Countdown(
                controller: state.timerController,
                seconds: 5,
                build: (_, double time) => Text(
                      time.toStringAsFixed(0),
                    ),
                interval: const Duration(seconds: 1),
                onFinished: () =>
                    context.read<LoginBloc>().add(const ResendTimerDone())),
          ],
        );
      },
    );
  }
}

class _SmsCodeInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.smsCode != current.smsCode,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: PinCodeTextField(
            key: const Key('loginForm_smsCodeInput_textField'),
            appContext: context,
            length: 4,
            keyboardType: TextInputType.number,
            pastedTextStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
                fieldHeight: 62,
                fieldWidth: 60,
                activeColor: Colors.black,
                selectedColor: Colors.black,
                errorBorderColor: Colors.black,
                inactiveColor: Colors.black),
            animationType: AnimationType.fade,
            onChanged: (smsCode) {
              context.read<LoginBloc>().add(SmsCodeChanged(smsCode));
            },
          ),
        );
      },
    );
  }
}

class _ResendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return ElevatedButton(
          key: const Key('loginForm_resend_raisedButton'),
          style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 55),
              side: const BorderSide(width: 2, color: Colors.black)),
          onPressed: state.resendReady
              ? () => context.read<LoginBloc>().add(const ResendSmsCode())
              : null,
          child: const Text(
            'Resend',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const SizedBox(
                width: 150,
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              )
            : ElevatedButton(
                key: const Key('loginForm_login_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(150, 55)),
                onPressed: state.isValid
                    ? () =>
                        context.read<LoginBloc>().add(const SmsCodeSubmitted())
                    : null,
                child: const Text(
                  'Verify',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
              );
      },
    );
  }
}

class _LoginInitial extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  const _LoginInitial({
    required this.phoneController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: const Alignment(0, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Salamti',
                style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 80),
              _PhoneInput(controller: phoneController),
              const SizedBox(height: 2),
              _PasswordInput(controller: passwordController),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () => Navigator.of(context)
                      .push<void>(ChangePasswordPage.route()),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              _FormLoginButton(),
              const SizedBox(height: 40),
              const Text(
                "Don't have an account?",
                style: TextStyle(fontSize: 16),
              ),
              _SignUpButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_phoneInput_textField'),
          controller: controller,
          onChanged: (phone) =>
              context.read<LoginBloc>().add(PhoneChanged(phone)),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 22),
          decoration: InputDecoration(
            prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 20, top: 15, bottom: 15),
                child: Text(
                  '+962 | ',
                  style: TextStyle(fontSize: 22),
                )),
            hintText: 'Phone Number',
            helperText: '',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            errorText: state.phone.displayError != null
                ? 'Invalid phone number'
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const _PasswordInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          controller: controller,
          onChanged: (password) =>
              context.read<LoginBloc>().add(PasswordChanged(password)),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          obscureText: true,
          style: const TextStyle(fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Password',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        );
      },
    );
  }
}

class _FormLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('loginForm_formLogin_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(150, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<LoginBloc>()
                        .add(const LoginFormSubmitted())
                    : null,
                child: const Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
              );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: const Key('loginForm_createAccount_flatButton'),
      onPressed: () => Navigator.of(context).push<void>(SignUpPage.route()),
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: const Text(
        "Create an account",
        style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline),
      ),
    );
  }
}
