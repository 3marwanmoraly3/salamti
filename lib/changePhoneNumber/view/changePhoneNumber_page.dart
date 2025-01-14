import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/changePhoneNumber/changePhoneNumber.dart';

class ChangePhoneNumberPage extends StatelessWidget {
  const ChangePhoneNumberPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const ChangePhoneNumberPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
        child: BlocProvider(
          create: (_) => ChangePhoneNumberBloc(
              authenticationRepository:
              context.read<AuthenticationRepository>()),
          child: const ChangePhoneNumberForm(),
        ),
      ),
    );
  }
}
