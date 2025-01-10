import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:salamti/pastActivities/pastActivities.dart';

class PastActivitiesScreen extends StatefulWidget {
  const PastActivitiesScreen({super.key});

  @override
  State<PastActivitiesScreen> createState() => _PastActivitiesState();
}

class _PastActivitiesState extends State<PastActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PastActivitiesBloc, PastActivitiesState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Past Activities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
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
          body: (state.loading)
              ? const Center(child: CircularProgressIndicator())
              : _pastActivitiesList(),
        );
      },
    );
  }

  Widget _pastActivitiesList() {
    return BlocBuilder<PastActivitiesBloc, PastActivitiesState>(
      buildWhen: (previous, current) =>
          previous.pastActivities != current.pastActivities,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.only(top: 20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.separated(
              itemCount: state.pastActivities.length,
              separatorBuilder: (context, index) => const Divider(
                    thickness: 1,
                    color: Colors.black26,
                  ),
              itemBuilder: (context, index) {
                final activity = state.pastActivities[index];
                final String emergencyType = activity["EmergencyType"];
                final DateTime requestTime = activity["RequestTime"].toDate();
                String formattedDate =
                    DateFormat('MMM dd - h:mm a').format(requestTime);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                                color: Color(0x66d9d9d9),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Center(
                              child: Image(
                                image: AssetImage(
                                    "assets/requestEmergency/images/$emergencyType.png"),
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatEmergencyType(emergencyType),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
        );
      },
    );
  }

  String _formatEmergencyType(String type) {
    switch (type) {
      case "medical":
        return "Medical";
      case "carCrash":
        return "Car\nCrash";
      case "fire":
        return "Fire";
      case "pedestrianCollision":
        return "Pedestrian\nCollision";
      case "armedThreat":
        return "Armed\nThreat";
      case "naturalDisaster":
        return "Natural\nDisaster";
      case "suicideAttempt":
        return "Suicide\nAttempt";
      case "abduction":
        return "Abduction";
      case "burglary":
        return "Burglary";
      case "assault":
        return "Assault";
      case "domesticViolence":
        return "Domestic\nViolence";
      case "trapped":
        return "Trapped";
      default:
        return type;
    }
  }
}
