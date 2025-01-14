import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/requestEmergency/requestEmergency.dart';
import 'package:google_maps_repository/google_maps_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';

class RequestEmergencyPage extends StatelessWidget {
  const RequestEmergencyPage({
    super.key,
    this.initialLongitude,
    this.initialLatitude,
  });

  final double? initialLongitude;
  final double? initialLatitude;

  static Route<void> route({double? longitude, double? latitude}) {
    return MaterialPageRoute<void>(
      builder: (_) => RequestEmergencyPage(
        initialLongitude: longitude,
        initialLatitude: latitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocProvider<RequestEmergencyBloc>(
        create: (_) {
          final bloc = RequestEmergencyBloc(
            googleMapsRepository: GoogleMapsRepository(),
            authenticationRepository: context.read<AuthenticationRepository>(),
          );

          if (initialLatitude != null && initialLongitude != null) {
            bloc
              ..add(CoordinatesChanged(initialLongitude!, initialLatitude!))
              ..add(const StatusChanged(RequestEmergencyStatus.emergencyType));
          }

          return bloc;
        },
        child: const RequestEmergencyScreen(),
      ),
    );
  }
}