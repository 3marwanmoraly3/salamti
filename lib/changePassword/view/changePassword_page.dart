import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/changePassword/changePassword.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const ChangePasswordPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/signup/images/bkg.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
        child: BlocProvider(
          create: (_) => ChangePasswordBloc(
              authenticationRepository:
              context.read<AuthenticationRepository>()),
          child: const ChangePasswordForm(),
        ),
      ),
    );
  }
}
