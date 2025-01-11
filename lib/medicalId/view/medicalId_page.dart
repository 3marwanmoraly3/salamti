import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/medicalId/medicalId.dart';

class MedicalIdPage extends StatelessWidget {
  const MedicalIdPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const MedicalIdPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
        child: BlocProvider<MedicalIdBloc>(
          create: (_) => MedicalIdBloc(authenticationRepository: context.read<AuthenticationRepository>()),
          child: const MedicalIdForm(),
        ),
      ),
    );
  }
}