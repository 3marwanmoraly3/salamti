import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salamti/app/app.dart';
import 'package:salamti/medicalId/medicalId.dart';
import 'package:salamti/changePassword/changePassword.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_circle_left_rounded,
                size: 60,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.zero,
            ),
          ),
          body: Align(
            alignment: const Alignment(0, -1 / 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Image(
                    image: AssetImage("assets/profile/images/person.png"),
                    width: 30,
                  ),
                  title: const Text(
                    "Account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  tileColor: const Color(0x82d9d9d9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  onTap: () {
                    Navigator.of(context)
                        .push(ChangePasswordPage.route());
                  },
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Image(
                    image: AssetImage("assets/profile/images/medicalId.png"),
                    width: 30,
                  ),
                  title: const Text(
                    "Medical Record",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  tileColor: const Color(0x82d9d9d9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  onTap: () {
                    Navigator.of(context)
                        .push(MedicalIdPage.route());
                  },
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Image(
                    image: AssetImage("assets/profile/images/logout.png"),
                    width: 30,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  tileColor: const Color(0x82d9d9d9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  onTap: () {
                    context.read<AppBloc>().add(const AppLogoutRequested());
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
