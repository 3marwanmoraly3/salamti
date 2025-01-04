import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/emergencyContacts/emergencyContacts.dart';

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const EmergencyContactsPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
        child: BlocProvider<EmergencyContactsBloc>(
          create: (_) => EmergencyContactsBloc(
              authenticationRepository:
                  context.read<AuthenticationRepository>()),
          child: const EmergencyContactsScreen(),
        ),
      ),
    );
  }
}
