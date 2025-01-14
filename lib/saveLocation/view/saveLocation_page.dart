import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/saveLocation/saveLocation.dart';
import 'package:google_maps_repository/google_maps_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';

class SaveLocationPage extends StatelessWidget {
  SaveLocationPage({super.key});

  final googleMapsRepository = GoogleMapsRepository();

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => SaveLocationPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocProvider<SaveLocationBloc>(
        create: (_) => SaveLocationBloc(
            googleMapsRepository: googleMapsRepository,
            authenticationRepository: context.read<AuthenticationRepository>()),
        child: const SaveLocationScreen(),
      ),
    );
  }
}
