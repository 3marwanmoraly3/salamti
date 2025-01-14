import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salamti/saveLocation/saveLocation.dart';
import 'package:location/location.dart';
import 'package:formz/formz.dart';

class SaveLocationScreen extends StatefulWidget {
  const SaveLocationScreen({super.key});

  @override
  State<SaveLocationScreen> createState() => _SaveLocationScreenState();
}

class _SaveLocationScreenState extends State<SaveLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SaveLocationBloc, SaveLocationState>(
      listener: (context, state) {
        if (state.status == SaveLocationStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Failed to save location')),
            );
        }
      },
      builder: (context, state) {
        if (state.status == SaveLocationStatus.pickLocation) {
          return const _PickLocation();
        } else if (state.status == SaveLocationStatus.nameLocation) {
          return const _NameLocation();
        } else {
          return Container();
        }
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
    return BlocBuilder<SaveLocationBloc, SaveLocationState>(
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
                  context.read<SaveLocationBloc>().add(CoordinatesChanged(
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
                      context.read<SaveLocationBloc>().add(
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
                    image: AssetImage("assets/requestEmergency/images/marker.png"),
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
                builder: (BuildContext context, ScrollController scrollController) {
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
          "Set Location",
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
        _ConfirmLocationButton(),
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
          const SizedBox(height: 20),
          _autoCompleteList(),
        ],
      ),
    );
  }

  Widget _autoCompleteList() {
    return BlocBuilder<SaveLocationBloc, SaveLocationState>(
      buildWhen: (previous, current) => previous.loading != current.loading,
      builder: (context, state) {
        return (state.loading)
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
                        .read<SaveLocationBloc>()
                        .add(SearchPlaceId(id));
                    _toggleExpanded();
                    final updatedState = await context
                        .read<SaveLocationBloc>()
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

  Future<void> _updateCurrentLocation({double? longitude, double? latitude}) async {
    if (longitude != null && latitude != null) {
      try {
        final GoogleMapController controller = await _googleMapsController.future;
        if (controller.toString().contains('Destroyed')) {
          return;
        }

        LatLng currentPosition = LatLng(latitude - 0.000400, longitude);
        CameraPosition newCameraPosition = CameraPosition(
          target: currentPosition,
          zoom: 18,
        );

        await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
      } catch (e) {
        print('Map animation error: $e');
      }
    }
  }
}

class _SearchInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaveLocationBloc, SaveLocationState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            key: const Key('saveLocationScreen_searchLocationInput_textField'),
            style: const TextStyle(fontSize: 22, color: Colors.white),
            onChanged: (search) =>
                context.read<SaveLocationBloc>().add(SearchChanged(search)),
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

class _ConfirmLocationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaveLocationBloc, SaveLocationState>(
      builder: (context, state) {
        return ElevatedButton(
          key: const Key('saveLocationScreen_confirmLocation_raisedButton'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, fixedSize: const Size(170, 55)),
          onPressed: () {
            context
                .read<SaveLocationBloc>()
                .add(const StatusChanged(SaveLocationStatus.nameLocation));
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

class _NameLocation extends StatelessWidget {
  const _NameLocation();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Save Location",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_circle_left_rounded,
              size: 60,
            ),
            onPressed: () {
              context
                  .read<SaveLocationBloc>()
                  .add(const StatusChanged(SaveLocationStatus.pickLocation));
            },
            padding: EdgeInsets.zero,
          ),
        ),
        body: Align(
          alignment: const Alignment(0, -1 / 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter Location Name",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _LocationNameInput(),
              const SizedBox(height: 4),
              _SaveLocationButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaveLocationBloc, SaveLocationState>(
      buildWhen: (previous, current) => previous.locationName != current.locationName,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TextField(
            key: const Key('saveLocationForm_locationNameInput_textField'),
            onChanged: (name) =>
                context.read<SaveLocationBloc>().add(LocationNameChanged(name)),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            style: const TextStyle(fontSize: 22),
            decoration: InputDecoration(
              hintText: 'Location Name',
              helperText: '',
              errorText: state.locationName.displayError != null
                  ? 'Invalid location name'
                  : null,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              filled: true,
              fillColor: Colors.white,
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
        );
      },
    );
  }
}

class _SaveLocationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaveLocationBloc, SaveLocationState>(
      builder: (context, state) {
        return state.formStatus.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
          key: const Key('saveLocationForm_save_raisedButton'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              fixedSize: const Size(170, 55)),
          onPressed: state.isValid
              ? () => context
              .read<SaveLocationBloc>()
              .add(const SaveLocationSubmitted())
              : null,
          child: const Text(
            'Save',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}