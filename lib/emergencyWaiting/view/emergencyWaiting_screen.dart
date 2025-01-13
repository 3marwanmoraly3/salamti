import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salamti/emergencyWaiting/emergencyWaiting.dart';
import 'package:salamti/espLocation/espLocation.dart';
import 'package:salamti/app/app.dart';

class EmergencyWaitingScreen extends StatefulWidget {
  const EmergencyWaitingScreen({super.key});

  @override
  State<EmergencyWaitingScreen> createState() => _EmergencyWaitingScreenState();
}

class _EmergencyWaitingScreenState extends State<EmergencyWaitingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmergencyWaitingBloc, EmergencyWaitingState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.status == EmergencyWaitingStatus.emergencyDetails) {
          return const _EmergencyDetails();
        } else if (state.status == EmergencyWaitingStatus.waiting) {
          return const _EmergencyWaiting();
        } else if (state.emergencyType == "") {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Container();
        }
      },
    );
  }
}

class _EmergencyWaiting extends StatefulWidget {
  const _EmergencyWaiting({Key? key}) : super(key: key);

  @override
  State<_EmergencyWaiting> createState() => _EmergencyWaitingState();
}

class _EmergencyWaitingState extends State<_EmergencyWaiting> {
  Map<String, BitmapDescriptor> markerIcons = {};
  Map<String, LatLng> previousLocations = {};

  final Completer<GoogleMapController> _googleMapsController =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    // Check if we need to start tracking immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<EmergencyWaitingBloc>().state;

      if (state.status == EmergencyWaitingStatus.waiting &&
          state.espIds != null &&
          state.caseId != null) {
        context.read<EspLocationBloc>().add(
              StartTrackingEsps(
                espIds: List<String>.from(state.espIds!),
                destination: LatLng(state.latitude!, state.longitude!),
                caseId: state.caseId!,
              ),
            );
      }
    });
  }

  AssetImage _getEspTypeIcon(String espType) {
    switch (espType.toLowerCase()) {
      case 'ambulance':
        return const AssetImage(
            "assets/emergencyWaiting/images/ambulance_sideView.png");
      case 'police':
        return const AssetImage(
            "assets/emergencyWaiting/images/police_sideView.png");
      case 'firetruck':
        return const AssetImage(
            "assets/emergencyWaiting/images/firetruck_sideView.png");
      default:
        return const AssetImage(
            "assets/emergencyWaiting/images/other_sideView.png");
        ;
    }
  }

  String _formatEspType(String espType) {
    switch (espType.toLowerCase()) {
      case 'hazmatunit':
        return 'Hazmat Unit';
      case 'tacticalunit':
        return 'Tactical Unit';
      case 'engineeringunit':
        return 'Engineering Unit';
      case 'transportunit':
        return 'Transport Unit';
      default:
        espType = espType.substring(0, 1).toUpperCase() + espType.substring(1);
        return espType;
    }
  }

  Future<void> _loadMarkerIcons() async {
    try {
      final markerTypes = {
        'ambulance': 'assets/emergencyWaiting/images/ambulance_topView.png',
        'police': 'assets/emergencyWaiting/images/police_topView.png',
        'firetruck': 'assets/emergencyWaiting/images/firetruck_topView.png',
        'hazmatunit': 'assets/emergencyWaiting/images/other_topView.png',
        'tacticalunit': 'assets/emergencyWaiting/images/other_topView.png',
        'engineeringunit': 'assets/emergencyWaiting/images/other_topView.png',
        'transportunit': 'assets/emergencyWaiting/images/other_topView.png',
        'destination': 'assets/emergencyWaiting/images/marker.png',
      };

      for (final entry in markerTypes.entries) {
        try {
          final iconData = await BitmapDescriptor.asset(
            ImageConfiguration(
              size: (entry.key == "destination")
                  ? Size(24, 24)
                  : Size(30, 60), // Very small base size
              devicePixelRatio: 2, // Reduced ratio to make icons smaller
            ),
            entry.value,
          );
          markerIcons[entry.key] = iconData;
        } catch (e) {
          print('Error loading marker icon for ${entry.key}: $e');
          markerIcons[entry.key] = BitmapDescriptor.defaultMarker;
        }
      }
      setState(() {});
    } catch (e) {
      print('Error in _loadMarkerIcons: $e');
    }
  }

  Set<Marker> _buildMarkers(EspLocationState espState) {
    final markers = <Marker>{};

    espState.espLocations.forEach((espId, currentLocation) {
      final hasArrived = espState.arrivedStatus[espId] ?? false;
      final espType = espState.espTypes[espId]?.toLowerCase() ?? 'default';

      // Calculate rotation based on actual movement
      double rotation = 0;
      if (!hasArrived && previousLocations.containsKey(espId)) {
        final prevLocation = previousLocations[espId]!;
        if (prevLocation != currentLocation) {
          // Add 180 degrees to flip the direction
          rotation =
              (_calculateBearing(prevLocation, currentLocation) + 180) % 360;
          print('ESP $espId rotation: $rotation degrees');
        }
      }

      // Store current location for next update
      previousLocations[espId] = currentLocation;

      try {
        markers.add(
          Marker(
            markerId: MarkerId('esp_$espId'),
            position: currentLocation,
            icon: markerIcons[espType] ?? BitmapDescriptor.defaultMarker,
            rotation: rotation,
            anchor: const Offset(0.5, 0.5),
            flat: true,
          ),
        );
      } catch (e) {
        print('Error adding marker for ESP $espId: $e');
      }
    });

    // Add destination marker
    if (espState.destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: espState.destination!,
          icon: markerIcons['destination'] ?? BitmapDescriptor.defaultMarker,
          zIndex: 1,
          flat: false,
        ),
      );
    }

    return markers;
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final startLat = start.latitude * pi / 180;
    final startLng = start.longitude * pi / 180;
    final endLat = end.latitude * pi / 180;
    final endLng = end.longitude * pi / 180;

    final y = sin(endLng - startLng) * cos(endLat);
    final x = cos(startLat) * sin(endLat) -
        sin(startLat) * cos(endLat) * cos(endLng - startLng);
    final bearing = atan2(y, x);

    // Convert to degrees
    return (bearing * 180 / pi + 360) % 360;
  }

  Set<Polyline> _buildRoutes(EspLocationState espState) {
    final polylines = <Polyline>{};

    espState.routes.forEach((espId, route) {
      if (!(espState.arrivedStatus[espId] ?? false)) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('route_$espId'),
            points: route,
            color: Colors.black,
            width: 6,
          ),
        );
      }
    });

    return polylines;
  }

  Widget _buildEtaItem(
      String espId, String espType, double? eta, bool hasArrived) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Image(
            image: _getEspTypeIcon(espType),
            width: 70,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _formatEspType(espType),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            hasArrived ? 'Arrived' : '${eta?.toStringAsFixed(0) ?? "..."} min',
            style: TextStyle(
              color: hasArrived ? Colors.green : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaList(EspLocationState state) {
    final groupedEsps = <String, List<Map<String, dynamic>>>{};

    state.espLocations.forEach((espId, location) {
      final espType = state.espTypes[espId] ?? 'unknown';
      final hasArrived = state.arrivedStatus[espId] ?? false;
      final eta = state.estimatedArrivalTimes[espId];

      groupedEsps.putIfAbsent(espType, () => []);
      groupedEsps[espType]!.add({
        'id': espId,
        'type': espType,
        'eta': eta,
        'arrived': hasArrived,
      });
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedEsps.length,
      itemBuilder: (context, index) {
        final espType = groupedEsps.keys.elementAt(index);
        final esps = groupedEsps[espType]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...esps.map((esp) => _buildEtaItem(
                  esp['id'],
                  esp['type'],
                  esp['eta'],
                  esp['arrived'],
                )),
            if (index < groupedEsps.length - 1)
              const Divider(color: Colors.white24, height: 32),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EmergencyWaitingBloc, EmergencyWaitingState>(
        listenWhen: (previous, current) {
          return previous.status != current.status ||
              previous.espIds != current.espIds ||
              previous.caseId != current.caseId;
        },
        listener: (context, state) {
          if (state.status == EmergencyWaitingStatus.waiting &&
              state.espIds != null &&
              state.caseId != null) {
            context.read<EspLocationBloc>().add(
                  StartTrackingEsps(
                    espIds: List<String>.from(state.espIds!),
                    destination: LatLng(state.latitude!, state.longitude!),
                    caseId: state.caseId!,
                  ),
                );
          }
        },
        child: BlocConsumer<EspLocationBloc, EspLocationState>(
          listener: (context, state) {
            if (state.isDone!) {
              context.read<AppBloc>().add(const EmergencyDone());
              Navigator.of(context).pop();
            }
          },
          builder: (context, espState) {
            return Stack(
              children: [
                GoogleMap(
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  rotateGesturesEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      context.read<EmergencyWaitingBloc>().state.latitude!,
                      context.read<EmergencyWaitingBloc>().state.longitude!,
                    ),
                    zoom: 16,
                  ),
                  markers: _buildMarkers(espState),
                  polylines: _buildRoutes(espState),
                  onMapCreated: (GoogleMapController controller) {
                    _googleMapsController.complete(controller);
                  },
                ),
                if (espState.error != null)
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red,
                      child: Text(
                        'Error: ${espState.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomSheet: BlocBuilder<EspLocationBloc, EspLocationState>(
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "ETA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (state.espLocations.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Waiting for emergency services...',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildEtaList(state),
                      ),
                    ),
                  const SizedBox(height: 10),
                  _emergencyGuidesButton(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emergencyGuidesButton() {
    return Container(
      width: 400,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0x82d9d9d9),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Emergency Guides",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Image(
            image: AssetImage("assets/emergencyWaiting/images/cpr.png"),
            width: 30,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _googleMapsController.future.then((controller) => controller.dispose());
    super.dispose();
  }
}

class _EmergencyDetails extends StatefulWidget {
  const _EmergencyDetails();

  @override
  State<_EmergencyDetails> createState() => _EmergencyDetailsState();
}

class _EmergencyDetailsState extends State<_EmergencyDetails> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String key, String initialText) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialText);
    } else if (_controllers[key]!.text != initialText) {
      _controllers[key]!.text = initialText;
    }
    return _controllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Help is on the way!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "If you can, please answer these questions to ensure the right resources are sent and any extra help arrives quickly.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildQuestions(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _submitSurveyButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(Map<String, dynamic> question, int index) {
    if (question.containsKey('boolMore')) {
      return _buildBoolMoreQuestion(question['boolMore'], index);
    } else if (question.containsKey('string')) {
      return _buildStringQuestions(question['string']['questions'], index);
    } else if (question.containsKey('bool') ||
        question.containsKey('boolAdd')) {
      String questionText = question.containsKey('bool')
          ? question['bool']['question']
          : question['boolAdd']['question'];
      return _buildBoolQuestion(questionText, index);
    } else if (question.containsKey('boolOr')) {
      return _buildBoolOrQuestions(question['boolOr']['questions'], index);
    } else if (question.containsKey('num') || question.containsKey('numAdd')) {
      String questionText = question.containsKey('num')
          ? question['num']['question']
          : question['numAdd']['question'];
      return _buildNumQuestion(questionText, index);
    }
    return const SizedBox.shrink();
  }

  Widget _buildBoolQuestion(String question, int index) {
    return BlocBuilder<EmergencyWaitingBloc, EmergencyWaitingState>(
      builder: (context, state) {
        final answer = state.answers[index] as bool?;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildBooleanChoice(
                  text: 'Yes',
                  isSelected: answer == true,
                  onTap: () {
                    context.read<EmergencyWaitingBloc>().add(
                          UpdateAnswer(index: index, answer: true),
                        );
                  },
                ),
                const SizedBox(width: 16),
                _buildBooleanChoice(
                  text: 'No',
                  isSelected: answer == false,
                  onTap: () {
                    context.read<EmergencyWaitingBloc>().add(
                          UpdateAnswer(index: index, answer: false),
                        );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBoolOrQuestions(List<String> questions, int index) {
    return BlocBuilder<EmergencyWaitingBloc, EmergencyWaitingState>(
      builder: (context, state) {
        final answers = Map<int, bool>.from(state.answers[index] ?? {});

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: questions.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final question = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBooleanChoice(
                      text: 'Yes',
                      isSelected: answers[questionIndex] == true,
                      onTap: () {
                        final updatedAnswers = Map<int, bool>.from(answers);
                        updatedAnswers[questionIndex] = true;
                        context.read<EmergencyWaitingBloc>().add(
                              UpdateAnswer(
                                  index: index, answer: updatedAnswers),
                            );
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildBooleanChoice(
                      text: 'No',
                      isSelected: answers[questionIndex] == false,
                      onTap: () {
                        final updatedAnswers = Map<int, bool>.from(answers);
                        updatedAnswers[questionIndex] = false;
                        context.read<EmergencyWaitingBloc>().add(
                              UpdateAnswer(
                                  index: index, answer: updatedAnswers),
                            );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuestions() {
    return BlocBuilder<EmergencyWaitingBloc, EmergencyWaitingState>(
      builder: (context, state) {
        if (state.questions == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            state.questions!.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _buildQuestionItem(state.questions![index], index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoolMoreQuestion(Map<String, dynamic> boolMore, int index) {
    return BlocBuilder<EmergencyWaitingBloc, EmergencyWaitingState>(
      builder: (context, state) {
        final currentAnswer = state.answers[index] as Map<String, dynamic>?;
        final bool? mainAnswer = currentAnswer?['mainAnswer'] as bool?;
        final subAnswers =
            (currentAnswer?['subAnswers'] as Map<dynamic, dynamic>?)
                    ?.cast<String, String>() ??
                {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              boolMore['question'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildBooleanChoice(
                  text: 'Yes',
                  isSelected: mainAnswer == true,
                  onTap: () {
                    context.read<EmergencyWaitingBloc>().add(
                          UpdateAnswer(
                            index: index,
                            answer: {
                              'mainAnswer': true,
                              'subAnswers': subAnswers,
                            },
                          ),
                        );
                  },
                ),
                const SizedBox(width: 16),
                _buildBooleanChoice(
                  text: 'No',
                  isSelected: mainAnswer == false,
                  onTap: () {
                    context.read<EmergencyWaitingBloc>().add(
                          UpdateAnswer(
                            index: index,
                            answer: {
                              'mainAnswer': false,
                              'subAnswers': {},
                            },
                          ),
                        );
                  },
                ),
              ],
            ),
            if (mainAnswer == true) ...[
              const SizedBox(height: 16),
              ...boolMore['subQuestions'].map<Widget>((subQ) {
                if (subQ.containsKey('string')) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...(subQ['string']['questions'] as List<String>)
                            .asMap()
                            .entries
                            .map((entry) {
                          final questionIndex = entry.key.toString();
                          final controllerKey =
                              'boolMore_${index}_$questionIndex';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _getController(
                                  controllerKey,
                                  subAnswers[questionIndex] ?? '',
                                ),
                                onChanged: (value) {
                                  final newSubAnswers =
                                      Map<String, String>.from(subAnswers);
                                  newSubAnswers[questionIndex] = value;
                                  context.read<EmergencyWaitingBloc>().add(
                                        UpdateAnswer(
                                          index: index,
                                          answer: {
                                            'mainAnswer': true,
                                            'subAnswers': newSubAnswers,
                                          },
                                        ),
                                      );
                                },
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNumQuestion(String question, int index) {
    return BlocBuilder<EmergencyWaitingBloc, EmergencyWaitingState>(
      builder: (context, state) {
        final controllerKey = 'num_$index';
        final answer = state.answers[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _getController(
                controllerKey,
                answer?.toString() ?? '',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final numValue = int.tryParse(value);
                if (numValue != null) {
                  context.read<EmergencyWaitingBloc>().add(
                        UpdateAnswer(index: index, answer: numValue),
                      );
                }
              },
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStringQuestions(List<String> questions, int index) {
    return BlocBuilder<EmergencyWaitingBloc, EmergencyWaitingState>(
      builder: (context, state) {
        final answers = Map<int, String>.from(state.answers[index] ?? {});

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: questions.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final controllerKey = 'string_${index}_$questionIndex';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _getController(
                    controllerKey,
                    answers[questionIndex] ?? '',
                  ),
                  onChanged: (value) {
                    final updatedAnswers = Map<int, String>.from(answers);
                    updatedAnswers[questionIndex] = value;
                    context.read<EmergencyWaitingBloc>().add(
                          UpdateAnswer(index: index, answer: updatedAnswers),
                        );
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBooleanChoice({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xfffd5f5f) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _submitSurveyButton() {
    return BlocBuilder<EmergencyWaitingBloc, EmergencyWaitingState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              context
                  .read<EmergencyWaitingBloc>()
                  .add(const SubmitAdditionalRequest());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              fixedSize: const Size(150, 55),
            ),
            child: state.loading == true
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
