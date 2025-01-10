import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/pastActivities/pastActivities.dart';

class PastActivitiesPage extends StatelessWidget {
  const PastActivitiesPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const PastActivitiesPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
        child: BlocProvider<PastActivitiesBloc>(
          create: (_) => PastActivitiesBloc(
              authenticationRepository:
                  context.read<AuthenticationRepository>()),
          child: const PastActivitiesScreen(),
        ),
      ),
    );
  }
}
