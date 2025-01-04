import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iss_2fa/signup/signup.dart';
import 'package:formz/formz.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state.status == SignUpStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Sign Up Failure')),
            );
          context.read<SignUpBloc>().add(const ResetFormStatus());
        }
      },
      builder: (context, state) {
        if (state.status == SignUpStatus.initial) {
          return _SignUpInitial(
            nameController: _nameController,
            phoneController: _phoneController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
          );
        } else {
          return _SignUpPhoneVerification();
        }
      },
    );
  }
}

class _SignUpPhoneVerification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 60,
          ),
          onPressed: () {
            context.read<SignUpBloc>().add(const ResetSignUpStatus());
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
                  "We have sent the code to +962${context.read<SignUpBloc>().state.phone.value}"),
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
                    _SignUpButton(),
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
    return BlocBuilder<SignUpBloc, SignUpState>(
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
                    context.read<SignUpBloc>().add(const ResendTimerDone())),
          ],
        );
      },
    );
  }
}

class _SmsCodeInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.smsCode != current.smsCode,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: PinCodeTextField(
            key: const Key('signUpForm_smsCodeInput_textField'),
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
              context.read<SignUpBloc>().add(SmsCodeChanged(smsCode));
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
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return ElevatedButton(
          key: const Key('signUpForm_resend_raisedButton'),
          style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 55),
              side: const BorderSide(width: 2, color: Colors.black)),
          onPressed: state.resendReady
              ? () => context.read<SignUpBloc>().add(const ResendSmsCode())
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

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
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
                key: const Key('signUpForm_signUp_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(150, 55)),
                onPressed: state.isValid
                    ? () =>
                        context.read<SignUpBloc>().add(const SmsCodeSubmitted())
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

class _SignUpInitial extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const _SignUpInitial({
    required this.nameController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 60,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          padding: EdgeInsets.zero,
        ),
      ),
      body: Align(
        alignment: const Alignment(0, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NameInput(controller: nameController),
              const SizedBox(height: 2),
              _PhoneInput(controller: phoneController),
              const SizedBox(height: 2),
              _PasswordInput(controller: passwordController),
              const SizedBox(height: 2),
              _ConfirmPasswordInput(controller: confirmPasswordController),
              const SizedBox(height: 16),
              _FormSignUpButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  final TextEditingController controller;

  const _NameInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_nameInput_textField'),
          controller: controller,
          onChanged: (name) =>
              context.read<SignUpBloc>().add(NameChanged(name)),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          keyboardType: TextInputType.name,
          style: const TextStyle(fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Name',
            helperText: '',
            errorText: state.name.displayError != null ? 'Invalid name' : null,
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

class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_phoneInput_textField'),
          controller: controller,
          onChanged: (phone) =>
              context.read<SignUpBloc>().add(PhoneChanged(phone)),
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
            errorText: state.phone.displayError != null
                ? 'Invalid phone number'
                : null,
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

class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const _PasswordInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_passwordInput_textField'),
          controller: controller,
          onChanged: (password) =>
              context.read<SignUpBloc>().add(PasswordChanged(password)),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          obscureText: true,
          style: const TextStyle(fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Password',
            helperText: '',
            errorText:
                state.password.displayError != null ? 'Invalid Password' : null,
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

class _ConfirmPasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const _ConfirmPasswordInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_confirmedPasswordInput_textField'),
          controller: controller,
          onChanged: (confirmPassword) => context
              .read<SignUpBloc>()
              .add(ConfirmedPasswordChanged(confirmPassword)),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          obscureText: true,
          style: const TextStyle(fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            helperText: '',
            errorText: state.confirmedPassword.displayError != null
                ? 'Passwords do not match'
                : null,
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

class _FormSignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('signUpForm_formSignUp_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(150, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<SignUpBloc>()
                        .add(const SignUpFormSubmitted())
                    : null,
                child: const Text(
                  'Sign Up',
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
