import 'package:flutter/material.dart';

class EmergencySteps extends StatelessWidget {
  const EmergencySteps({super.key, required this.guide});

  final Map<String, dynamic> guide;

  static Route<void> route(Map<String, dynamic> guide) {
    return MaterialPageRoute<void>(
        builder: (_) => EmergencySteps(guide: guide));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                guide["name"],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
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
            body: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ListView.builder(
                itemCount: guide["steps"].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "${index + 1}) ${guide["steps"][index]}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            )),
      ),
    );
  }
}
