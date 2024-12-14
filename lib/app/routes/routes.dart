import 'package:flutter/widgets.dart';
import 'package:salamti/app/app.dart';
import 'package:salamti/home/home.dart';
import 'package:salamti/login/login.dart';
import 'package:salamti/splash/splash.dart';

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