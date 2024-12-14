import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/requestEmergency/requestEmergency.dart';
import 'package:google_maps_repository/google_maps_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';

class RequestEmergencyPage extends StatelessWidget {
  RequestEmergencyPage({super.key});

  final googleMapsRepository = GoogleMapsRepository();

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => RequestEmergencyPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocProvider<RequestEmergencyBloc>(
        create: (_) => RequestEmergencyBloc(
            googleMapsRepository: googleMapsRepository,
            authenticationRepository: context.read<AuthenticationRepository>()),
        child: const RequestEmergencyScreen(),
      ),
    );
  }
}
