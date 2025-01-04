import 'package:flutter/material.dart';
import 'package:salamti/emergencyContacts/emergencyContacts.dart';
import 'package:salamti/profile/profile.dart';
import 'package:salamti/requestEmergency/requestEmergency.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 60, right: 20),
        child: Column(
          children: [
            _TopNavBar(),
            const SizedBox(height: 40),
            _RequestEmergency(),
            const SizedBox(height: 40),
            const Row(
              children: [
                Text(
                  "Emergency Resources",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _EmergencyResources(),
          ],
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Salamti",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () {
            showGeneralDialog(
              useRootNavigator: false,
              context: context,
              barrierDismissible: true,
              transitionDuration: const Duration(milliseconds: 250),
              barrierLabel: MaterialLocalizations.of(context).dialogLabel,
              barrierColor: Colors.black.withOpacity(0.5),
              pageBuilder: (context, _, __) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        height: 190,
                        padding:
                            const EdgeInsets.only(left: 50, top: 60, right: 50),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.access_time_filled_rounded,
                                          color: Colors.black,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white),
                                        iconSize: 26,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const DefaultTextStyle(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                        child: Text(
                                          "Activity",
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).push<void>(
                                              EmergencyContactsPage.route());
                                        },
                                        icon: const Icon(
                                          Icons.contact_emergency_rounded,
                                          color: Colors.black,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white),
                                        iconSize: 26,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const DefaultTextStyle(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                        child: Text(
                                          "Emergency\nContacts",
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context)
                                              .push<void>(ProfilePage.route());
                                        },
                                        icon: const Icon(
                                          Icons.person_rounded,
                                          color: Colors.black,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white),
                                        iconSize: 26,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const DefaultTextStyle(
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                        child: Text(
                                          "Profile",
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              height: 5,
                              width: 70,
                              decoration: BoxDecoration(
                                color: const Color(0x82d9d9d9),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ],
                        )),
                  ],
                );
              },
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ).drive(Tween<Offset>(
                    begin: const Offset(0, -1.0),
                    end: Offset.zero,
                  )),
                  child: child,
                );
              },
            );
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          iconSize: 26,
          padding: const EdgeInsets.all(12),
        )
      ],
    );
  }
}

class _RequestEmergency extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0x82d9d9d9),
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).push<void>(RequestEmergencyPage.route()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfffd5f5f),
              shadowColor: Colors.transparent,
              fixedSize: const Size(350, 60),
            ),
            child: const Text(
              "REQUEST EMERGENCY",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ),
          const Column(
            children: [
              ListTile(
                title: Text(
                  "Add Location",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                leading: Icon(Icons.add_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmergencyResources extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 115,
          width: 165,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0x82d9d9d9),
          ),
          child: const Stack(
            children: [
              Text(
                "Guides",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Image(
                  image: AssetImage("assets/home/images/cpr.png"),
                  width: 35,
                  height: 35,
                ),
              )
            ],
          ),
        ),
        Container(
          height: 115,
          width: 165,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0x82d9d9d9),
          ),
          child: const Stack(
            children: [
              Text(
                "Helpful\nLocations",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Image(
                  image: AssetImage("assets/home/images/map.png"),
                  width: 35,
                  height: 35,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
