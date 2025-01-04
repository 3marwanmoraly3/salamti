import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iss_2fa/issProject_bloc_observer.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:iss_2fa/app.dart';
import 'package:authentication_repository/authentication_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = const IssProjectBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );

  final authenticationRepository = AuthenticationRepository();

  runApp(IssProjectApp(authenticationRepository: authenticationRepository));
}
