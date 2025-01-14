import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/changePhoneNumber/changePhoneNumber.dart';
import 'package:formz/formz.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';

class ChangePhoneNumberForm extends StatefulWidget {
  const ChangePhoneNumberForm({super.key});

  @override
  State<ChangePhoneNumberForm> createState() => _ChangePhoneNumberFormState();
}

class _ChangePhoneNumberFormState extends State<ChangePhoneNumberForm> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePhoneNumberBloc, ChangePhoneNumberState>(
      listener: (context, state) {
        if (state.status == ChangePhoneNumberStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Changing Phone Failed')),
            );
          context.read<ChangePhoneNumberBloc>().add(const ResetFormStatus());
        }
      },
      builder: (context, state) {
        if (state.status == ChangePhoneNumberStatus.initial) {
          return _PasswordForm();
        } else if (state.status == ChangePhoneNumberStatus.phoneVerification) {
          return _PhoneVerification();
        } else {
          return _PhoneForm();
        }
      },
    );
  }
}

class _PhoneVerification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Change Phone Number",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 60,
          ),
          onPressed: () {
            context
                .read<ChangePhoneNumberBloc>()
                .add(const ResetChangePhoneNumberStatus());
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
                  "We have sent the code to +962${context.read<ChangePhoneNumberBloc>().state.phone.value}"),
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
    return BlocBuilder<ChangePhoneNumberBloc, ChangePhoneNumberState>(
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
                    .read<ChangePhoneNumberBloc>()
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
    return BlocBuilder<ChangePhoneNumberBloc, ChangePhoneNumberState>(
      buildWhen: (previous, current) => previous.smsCode != current.smsCode,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: PinCodeTextField(
            key: const Key('changePhoneNumberForm_smsCodeInput_textField'),
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
              context.read<ChangePhoneNumberBloc>().add(SmsCodeChanged(smsCode));
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
    return BlocBuilder<ChangePhoneNumberBloc, ChangePhoneNumberState>(
      builder: (context, state) {
        return ElevatedButton(
          key: const Key('changePhoneNumberForm_resend_raisedButton'),
          style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 55),
              side: const BorderSide(width: 2, color: Colors.black)),
          onPressed: state.resendReady
              ? () =>
                  context.read<ChangePhoneNumberBloc>().add(const ResendSmsCode())
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
    return BlocBuilder<ChangePhoneNumberBloc, ChangePhoneNumberState>(
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
                key: const Key('changePhoneNumberForm_verify_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(150, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<ChangePhoneNumberBloc>()
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Change Phone Number",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            size: 60,
          ),
          onPressed: () {
            context
                .read<ChangePhoneNumberBloc>()
                .add(const ResetChangePhoneNumberStatus());
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
              _PhoneInput(),
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePhoneNumberBloc, ChangePhoneNumberState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return TextField(
          key: const Key('changePhoneNumberForm_phoneInput_textField'),
          onChanged: (phone) =>
              context.read<ChangePhoneNumberBloc>().add(PhoneChanged(phone)),
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
    return BlocBuilder<ChangePhoneNumberBloc, ChangePhoneNumberState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('changePhoneNumber_phoneForm_raisedButton'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    fixedSize: const Size(170, 55)),
                onPressed: state.isValid
                    ? () => context
                        .read<ChangePhoneNumberBloc>()
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
          "Change Phone Number",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                "Enter Your Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const _PasswordInput(),
              const SizedBox(height: 4),
              _PasswordFormButton(),
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
    return BlocBuilder<ChangePhoneNumberBloc, ChangePhoneNumberState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('changePhoneNumberForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<ChangePhoneNumberBloc>().add(PasswordChanged(password)),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          obscureText: true,
          style: const TextStyle(fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Password',
            helperText: '',
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

class _PasswordFormButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePhoneNumberBloc, ChangePhoneNumberState>(
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
                        .read<ChangePhoneNumberBloc>()
                        .add(const PasswordFormSubmitted())
                    : null,
                child: const Text(
                  'Continue',
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
