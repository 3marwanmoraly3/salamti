import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/emergencyWaiting/emergencyWaiting.dart';
import 'package:google_maps_repository/google_maps_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:salamti/espLocation/espLocation.dart';

class EmergencyWaitingPage extends StatelessWidget {
  EmergencyWaitingPage({super.key});

  final googleMapsRepository = GoogleMapsRepository();

  static Page<void> page() => MaterialPage<void>(child: EmergencyWaitingPage());

  @override
  Widget build(BuildContext context) {
    print('Building EmergencyWaitingPage');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MultiBlocProvider(
        providers: [
          BlocProvider<EmergencyWaitingBloc>(
            create: (_) {
              print('Creating EmergencyWaitingBloc');
              final bloc = EmergencyWaitingBloc(
                googleMapsRepository: googleMapsRepository,
                authenticationRepository: context.read<AuthenticationRepository>(),
              );
              print('Created EmergencyWaitingBloc');
              return bloc;
            },
          ),
          BlocProvider<EspLocationBloc>(
            create: (_) {
              print('Creating EspLocationBloc');
              final bloc = EspLocationBloc(
                googleMapsRepository: googleMapsRepository,
                authenticationRepository: context.read<AuthenticationRepository>(),
              );
              print('Created EspLocationBloc');
              return bloc;
            },
          ),
        ],
        child: const EmergencyWaitingScreen(),
      ),
    );
  }
}
