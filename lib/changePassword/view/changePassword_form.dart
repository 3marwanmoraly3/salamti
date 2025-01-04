import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iss_2fa/changePassword/changePassword.dart';
import 'package:formz/formz.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      listener: (context, state) {
        if (state.status == ChangePasswordStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Changing Password Failed')),
            );
          context.read<ChangePasswordBloc>().add(const ResetFormStatus());
        }
      },
      builder: (context, state) {
        if (state.status == ChangePasswordStatus.initial) {
          return _PhoneForm(
            phoneController: _phoneController,
          );
        } else if (state.status == ChangePasswordStatus.phoneVerification) {
          return _ChangePasswordPhoneVerification();
        } else {
          return _PasswordForm();
        }
      },
    );
  }
}

class _ChangePasswordPhoneVerification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 60,
          ),
          onPressed: () {
            context
                .read<ChangePasswordBloc>()
                .add(const ResetChangePasswordStatus());
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
                  "We have sent the code to +962${context.read<ChangePasswordBloc>().state.phone.value}"),
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
                    _VerifyPhoneButton(),
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
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
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
                onFinished: () => context
                    .read<ChangePasswordBloc>()
                    .add(const ResendTimerDone())),
          ],
        );
      },
    );
  }
}

class _SmsCodeInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      buildWhen: (previous, current) => previous.smsCode != current.smsCode,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: PinCodeTextField(
            key: const Key('changePasswordForm_smsCodeInput_textField'),
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
              context.read<ChangePasswordBloc>().add(SmsCodeChanged(smsCode));
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
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      builder: (context, state) {
        return ElevatedButton(
          key: const Key('changePasswordForm_resend_raisedButton'),
          style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 55),
              side: const BorderSide(width: 2, color: Colors.black)),
          onPressed: state.resendReady
              ? () =>
                  context.read<ChangePasswordBloc>().add(const ResendSmsCode())
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

class _VerifyPhoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
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
                key: const Key('changePasswordForm_verify_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(150, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<ChangePasswordBloc>()
                        .add(const SmsCodeSubmitted())
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

class _PhoneForm extends StatelessWidget {
  final TextEditingController phoneController;

  const _PhoneForm({
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Change Password",
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
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter Your Phone Number",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _PhoneInput(controller: phoneController),
              const SizedBox(height: 4),
              _PhoneFormButton(),
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
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return TextField(
          key: const Key('changePasswordForm_phoneInput_textField'),
          controller: controller,
          onChanged: (phone) =>
              context.read<ChangePasswordBloc>().add(PhoneChanged(phone)),
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

class _PhoneFormButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('changePasswordForm_phoneForm_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(170, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<ChangePasswordBloc>()
                        .add(const PhoneFormSubmitted())
                    : null,
                child: const Text(
                  'Send Code',
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

class _PasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 60,
          ),
          onPressed: () {
            context
                .read<ChangePasswordBloc>()
                .add(const ResetChangePasswordStatus());
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
                "Enter Your New Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const _PasswordInput(),
              const SizedBox(height: 2),
              const _ConfirmPasswordInput(),
              const SizedBox(height: 4),
              _ChangePasswordButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('changePasswordForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<ChangePasswordBloc>().add(PasswordChanged(password)),
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
  const _ConfirmPasswordInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('changePasswordForm_confirmedPasswordInput_textField'),
          onChanged: (confirmPassword) => context
              .read<ChangePasswordBloc>()
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

class _ChangePasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key:
                    const Key('changePasswordForm_changePassword_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(260, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<ChangePasswordBloc>()
                        .add(const ChangePasswordFormSubmitted())
                    : null,
                child: const Text(
                  'Change Password',
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
