import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salamti/requestEmergency/requestEmergency.dart';
import 'package:location/location.dart';

class RequestEmergencyScreen extends StatefulWidget {
  const RequestEmergencyScreen({super.key});

  @override
  State<RequestEmergencyScreen> createState() => _RequestEmergencyScreenState();
}

class _RequestEmergencyScreenState extends State<RequestEmergencyScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestEmergencyBloc, RequestEmergencyState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.status == RequestEmergencyStatus.pickLocation) {
          return const _PickLocation();
        } else if (state.status == RequestEmergencyStatus.emergencyType) {
          return const _EmergencyType();
        } else if (state.status == RequestEmergencyStatus.emergencyDetails) {
          return const _EmergencyDetails();
        } else if (state.status == RequestEmergencyStatus.waiting) {
          return const _EmergencyWaiting();
        } else {
          return Container();
        }
      },
    );
  }
}

class _EmergencyWaiting extends StatefulWidget {
  const _EmergencyWaiting();

  @override
  State<_EmergencyWaiting> createState() => _EmergencyWaitingState();
}

class _EmergencyWaitingState extends State<_EmergencyWaiting> {
  final Completer<GoogleMapController> _googleMapsController =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<RequestEmergencyBloc, RequestEmergencyState>(
      listener: (context, state) {},
      builder: (context, state) {
        return GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          rotateGesturesEnabled: false,
          initialCameraPosition: CameraPosition(
            target: LatLng(state.latitude!, state.longitude!),
            zoom: 18,
          ),
          onMapCreated: (GoogleMapController controller) {
            _googleMapsController.complete(controller);
          },
        );
      },
    ));
  }
}

class _EmergencyDetails extends StatefulWidget {
  const _EmergencyDetails();

  @override
  State<_EmergencyDetails> createState() => _EmergencyDetailsState();
}

class _EmergencyDetailsState extends State<_EmergencyDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 60, right: 20),
        child: ListView(
          children: [
            const Text(
              "Help is on the way!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "If you can, please answer these questions to ensure the right resources are sent and any extra help arrives quickly.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            _emergencySurvey(),
            _submitSurveyButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _submitSurveyButton() {
    return BlocBuilder<RequestEmergencyBloc, RequestEmergencyState>(
        builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            context
                .read<RequestEmergencyBloc>()
                .add(const SubmitAdditionalRequest());
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, fixedSize: const Size(150, 55)),
          child: state.loading == true
              ? const CircularProgressIndicator()
              : const Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
        ),
      );
    });
  }

  Widget _emergencySurvey() {
    return BlocBuilder<RequestEmergencyBloc, RequestEmergencyState>(
      builder: (context, state) {
        if (state.questions == null || state.questions!.isEmpty) {
          return const Center(child: Text('No questions available'));
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: state.questions!.length,
            itemBuilder: (context, index) {
              final question = state.questions![index];

              if (question.containsKey("string")) {
                final stringQuestions = question["string"] is List
                    ? question["string"] as List<String>
                    : question["string"]["questions"] as List<String>;
                return _buildStringQuestions(stringQuestions, index);
              }

              if (question.containsKey("bool") ||
                  question.containsKey("boolMore") ||
                  question.containsKey("boolAdd") ||
                  question.containsKey("boolOr")) {
                String questionText = '';
                if (question.containsKey("bool")) {
                  questionText = question["bool"]["question"];
                } else if (question.containsKey("boolMore")) {
                  questionText = question["boolMore"]["question"];
                } else if (question.containsKey("boolAdd")) {
                  questionText = question["boolAdd"]["question"];
                } else {
                  questionText = question["boolOr"]["questions"][0];
                }
                return _buildBoolQuestion(questionText, index);
              }

              if (question.containsKey("num") ||
                  question.containsKey("numAdd")) {
                String questionText = question.containsKey("num")
                    ? question["num"]["question"]
                    : question["numAdd"]["question"];
                return _buildNumQuestion(questionText, index);
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildStringQuestions(List<String> questions, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questions.map((question) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) {
                context.read<RequestEmergencyBloc>().add(
                      UpdateAnswer(index: index, answer: value),
                    );
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
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBoolQuestion(String question, int index) {
    return BlocBuilder<RequestEmergencyBloc, RequestEmergencyState>(
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
                  onTap: () => context.read<RequestEmergencyBloc>().add(
                        UpdateAnswer(index: index, answer: true),
                      ),
                ),
                const SizedBox(width: 16),
                _buildBooleanChoice(
                  text: 'No',
                  isSelected: answer == false,
                  onTap: () => context.read<RequestEmergencyBloc>().add(
                        UpdateAnswer(index: index, answer: false),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
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

  Widget _buildNumQuestion(String question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final numValue = int.tryParse(value);
            if (numValue != null) {
              context.read<RequestEmergencyBloc>().add(
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
  }
}

class _EmergencyType extends StatefulWidget {
  const _EmergencyType();

  @override
  State<_EmergencyType> createState() => _EmergencyTypeState();
}

class _EmergencyTypeState extends State<_EmergencyType> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestEmergencyBloc, RequestEmergencyState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text(
                  "Emergency Type",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
                centerTitle: false,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_circle_left_rounded,
                    size: 60,
                  ),
                  onPressed: () {
                    context.read<RequestEmergencyBloc>().add(
                        const StatusChanged(
                            RequestEmergencyStatus.pickLocation));
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: [
                        _emergencyTypeButton(type: "medical", text: "Medical"),
                        _emergencyTypeButton(
                            type: "carCrash", text: "Car\nCrash"),
                        _emergencyTypeButton(type: "fire", text: "Fire"),
                        _emergencyTypeButton(
                            type: "pedestrianCollision",
                            text: "Pedestrian\nCollision"),
                        _emergencyTypeButton(
                            type: "armedThreat", text: "Armed\nThreat"),
                        _emergencyTypeButton(
                            type: "naturalDisaster", text: "Natural\nDisaster"),
                        _emergencyTypeButton(
                            type: "suicideAttempt", text: "Suicide\nAttempt"),
                        _emergencyTypeButton(
                            type: "abduction", text: "Abduction"),
                        _emergencyTypeButton(
                            type: "burglary", text: "Burglary"),
                        _emergencyTypeButton(type: "assault", text: "Assault"),
                        _emergencyTypeButton(
                            type: "domesticViolence",
                            text: "Domestic\nViolence"),
                        _emergencyTypeButton(type: "trapped", text: "Trapped"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: _confirmEmergencyType(),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _emergencyTypeButton({required String type, required String text}) {
    return BlocBuilder<RequestEmergencyBloc, RequestEmergencyState>(
      builder: (BuildContext context, state) {
        return Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context
                    .read<RequestEmergencyBloc>()
                    .add(EmergencyTypeChanged(type));
              },
              style: ButtonStyle(
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor:
                      const WidgetStatePropertyAll(Color(0x66d9d9d9)),
                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                  fixedSize: const WidgetStatePropertyAll(Size(60, 60)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      side: (state.emergencyType != null &&
                              state.emergencyType == type)
                          ? const BorderSide(color: Color(0xfffd5f5f), width: 3)
                          : BorderSide.none,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))))),
              child: Image(
                image: AssetImage("assets/requestEmergency/images/$type.png"),
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            )
          ],
        );
      },
    );
  }

  Widget _confirmEmergencyType() {
    return BlocBuilder<RequestEmergencyBloc, RequestEmergencyState>(
      buildWhen: (previous, current) => (previous.emergencyType == null ||
          (previous.loading != current.loading)),
      builder: (context, state) {
        return ElevatedButton(
          key: const Key(
              'requestEmergencyScreen_confirmEmergencyType_raisedButton'),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xfffd5f5f),
              fixedSize: const Size(350, 60)),
          onPressed: (state.emergencyType == null)
              ? null
              : () {
                  context
                      .read<RequestEmergencyBloc>()
                      .add(const EmergencyRequested());
                },
          child: (state.loading!)
              ? const CircularProgressIndicator()
              : const Text(
                  'REQUEST EMERGENCY',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
        );
      },
    );
  }
}

class _PickLocation extends StatefulWidget {
  const _PickLocation();

  @override
  State<_PickLocation> createState() => _PickLocationState();
}

class _PickLocationState extends State<_PickLocation> {
  @override
  void initState() {
    super.initState();
    _controller.addListener(_onDragUpdate);
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _controller.removeListener(_onDragUpdate);
    _controller.dispose();
    super.dispose();
  }

  bool _isExpanded = false;
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  final Location _locationController = Location();
  final Completer<GoogleMapController> _googleMapsController =
      Completer<GoogleMapController>();
  static const CameraPosition _kPSUT = CameraPosition(
    target: LatLng(32.023150, 35.876200),
    zoom: 18,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestEmergencyBloc, RequestEmergencyState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                rotateGesturesEnabled: false,
                initialCameraPosition: _kPSUT,
                onMapCreated: (GoogleMapController controller) {
                  _googleMapsController.complete(controller);
                },
                onCameraMove: (cameraPosition) {
                  context.read<RequestEmergencyBloc>().add(CoordinatesChanged(
                      cameraPosition.target.longitude,
                      cameraPosition.target.latitude + 0.000400));
                },
              ),
              Positioned(
                right: 20,
                bottom: 300,
                child: IconButton(
                  icon: const Icon(
                    Icons.gps_fixed_rounded,
                    color: Colors.white,
                  ),
                  iconSize: 26,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    LocationData currentLocation =
                        await _locationController.getLocation();
                    if (currentLocation.latitude != null &&
                        currentLocation.longitude != null) {
                      context.read<RequestEmergencyBloc>().add(
                          CoordinatesChanged(currentLocation.longitude!,
                              currentLocation.latitude! + 0.000400));
                      await _updateCurrentLocation(
                          longitude: currentLocation.longitude,
                          latitude: currentLocation.latitude);
                    }
                  },
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 223),
                  child: Image(
                    image:
                        AssetImage("assets/requestEmergency/images/marker.png"),
                    width: 22,
                  ),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.34,
                minChildSize: 0.34,
                maxChildSize: 0.94,
                snapSizes: const [0.34, 0.94],
                snap: true,
                controller: _controller,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        firstChild: _expandedContent(),
                        secondChild: _collapsedContent(),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 20,
                top: 60,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.white, Colors.transparent],
                      stops: [0.6, 0.7],
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_circle_left_rounded,
                      size: 60,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _collapsedContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 70,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0x82d9d9d9),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Set Your Emergency Location",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 2),
        const Text(
          "Drag map to move pin",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const Divider(
          color: Color(0x82d9d9d9),
          height: 30,
          thickness: 3,
        ),
        GestureDetector(
          onTap: _toggleExpanded,
          child: _searchExpandButton(),
        ),
        const SizedBox(height: 16),
        _ConfirmDestinationButton(),
      ],
    );
  }

  Widget _searchExpandButton() {
    return Container(
      width: 350,
      height: 55,
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
            "Search Location",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Icon(
            Icons.search_rounded,
            size: 26,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _expandedContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.94,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 70,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0x82d9d9d9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Search Locations",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          _SearchInput(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "Saved Locations",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0x82d9d9d9),
            thickness: 3,
          ),
          _autoCompleteList(),
        ],
      ),
    );
  }

  Widget _autoCompleteList() {
    return BlocBuilder<RequestEmergencyBloc, RequestEmergencyState>(
      buildWhen: (previous, current) => previous.loading != current.loading,
      builder: (context, state) {
        return (state.loading == true)
            ? Container(
                padding: const EdgeInsets.only(top: 20),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Expanded(
                child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: state.autoCompleteList?.length ?? 0,
                    separatorBuilder: (context, index) => const Divider(
                          color: Color(0x82d9d9d9),
                        ),
                    itemBuilder: (context, index) {
                      final location = state.autoCompleteList?[index];
                      final String name = location["name"];
                      final String id = location["id"];
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        onTap: () async {
                          final previousLatitude = state.latitude;
                          final previousLongitude = state.longitude;
                          context
                              .read<RequestEmergencyBloc>()
                              .add(SearchPlaceId(id));
                          _toggleExpanded();
                          final updatedState = await context
                              .read<RequestEmergencyBloc>()
                              .stream
                              .firstWhere((state) =>
                                  state.latitude != previousLatitude &&
                                  state.longitude != previousLongitude);

                          await _updateCurrentLocation(
                              longitude: updatedState.longitude,
                              latitude: updatedState.latitude);
                        },
                      );
                    }),
              );
      },
    );
  }

  void _onDragUpdate() {
    if (_controller.size >= 0.6 && !_isExpanded) {
      setState(() => _isExpanded = true);
    } else if (_controller.size < 0.6 && _isExpanded) {
      setState(() => _isExpanded = false);
    }
  }

  void _toggleExpanded() {
    final targetSize = _isExpanded ? 0.34 : 0.94;
    _controller.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();

    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await _locationController.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    LocationData currentLocation = await _locationController.getLocation();
    await _updateCurrentLocation(
        longitude: currentLocation.longitude,
        latitude: currentLocation.latitude);
  }

  Future<void> _updateCurrentLocation(
      {double? longitude, double? latitude}) async {
    if (longitude != null && latitude != null) {
      LatLng currentPosition = LatLng(latitude - 0.000400, longitude);
      CameraPosition newCameraPosition =
          CameraPosition(target: currentPosition, zoom: 18);
      GoogleMapController controller = await _googleMapsController.future;
      await controller
          .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
    }
  }
}

class _SearchInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestEmergencyBloc, RequestEmergencyState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            key: const Key('pickLocationScreen_searchLocationInput_textField'),
            style: const TextStyle(fontSize: 22, color: Colors.white),
            onChanged: (search) =>
                context.read<RequestEmergencyBloc>().add(SearchChanged(search)),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              suffixIcon: const Icon(
                Icons.search_rounded,
                size: 26,
                color: Colors.white,
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 70),
              hintText: 'Search Location',
              hintStyle: const TextStyle(color: Colors.white),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmDestinationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestEmergencyBloc, RequestEmergencyState>(
      builder: (context, state) {
        return ElevatedButton(
          key: const Key(
              'requestEmergencyScreen_confirmDestination_raisedButton'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, fixedSize: const Size(170, 55)),
          onPressed: () {
            context
                .read<RequestEmergencyBloc>()
                .add(const StatusChanged(RequestEmergencyStatus.emergencyType));
          },
          child: const Text(
            'Confirm',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}
