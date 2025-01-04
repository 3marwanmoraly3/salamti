import 'package:flutter/widgets.dart';
import 'package:iss_2fa/app/app.dart';
import 'package:iss_2fa/home/home.dart';
import 'package:iss_2fa/login/login.dart';
import 'package:iss_2fa/splash/splash.dart';

List<Page<dynamic>> onGenerateAppViewPages(
    AppStatus state,
    List<Page<dynamic>> pages,
    ) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
    default:
      return [SplashPage.page()];
  }
}