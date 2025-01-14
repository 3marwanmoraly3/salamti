import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:salamti/emergencyGuides/emergencyGuides.dart';

class EmergencyGuides extends StatelessWidget {
  const EmergencyGuides({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const EmergencyGuides());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "Emergency Guides",
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
            body: ListView.builder(
              itemCount: guidesData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(EmergencySteps.route(guidesData[index]));
                      },
                      child: _guideButton(guidesData[index])),
                );
              },
            )),
      ),
    );
  }

  Widget _guideButton(Map<String, dynamic> guide) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Image.asset(
                  'assets/emergencyGuides/images/${guide["image"]}.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: Colors.black.withAlpha(0),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFD9D9D9),
                  Color(0x99D9D9D9),
                  Color(0x00D9D9D9),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                guide["name"],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
