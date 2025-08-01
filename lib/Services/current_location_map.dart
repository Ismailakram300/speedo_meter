import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../distance_tracking.dart';
import '../widgets/stat_row.dart';

class CurrentLocationMap extends StatefulWidget {
  const CurrentLocationMap({Key? key}) : super(key: key);

  @override
  State<CurrentLocationMap> createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<CurrentLocationMap> with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observe app lifecycle
    _getCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If app comes back from background (e.g., after opening settings)
    if (state == AppLifecycleState.resumed && _currentPosition == null) {
      _getCurrentLocation(); // Retry fetching location
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Show dialog to open location settings
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Location Disabled"),
          content: const Text("Please enable location services."),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission permanently denied.")),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _markers['currentLocation'] = Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    });
    await _getAddressFromLatLng(position);

  }
  String? _currentAddress;
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      setState(() {
        _currentAddress =
        "${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
      });

    } catch (e) {
      print("Error fetching address: $e");
      setState(() {
        _currentAddress = "Unable to fetch address.";
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final tracker = DistanceTracker();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                14,
              ),
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
              child: Container(
                width: double.infinity,
                height: 300.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                child: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 14,
                  ),
                  markers: _markers.values.toSet(),
                ),
              ),
            ),
            Column(
              children: [
                if (_currentAddress != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red ,size: 40,),
                        Expanded(
                          child: Text(
                            _currentAddress!,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 10,),
                StatRow(
                  title1: 'Distance',
                  value1: '${DistanceTracker().totalKm.toStringAsFixed(2)} km',
                  title2: 'Top Speed',
                  value2: '${DistanceTracker().topSpeed.toStringAsFixed(1)} km/h',
                ),
                StatRow(
                  title1: 'Avg Speed',
                  value1: '${DistanceTracker().averageSpeed.toStringAsFixed(1)} km/h',
                  title2: 'Duration',
                  value2: 'Time: ${_formatDuration(tracker.elapsedTime)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(duration.inHours);
    final m = twoDigits(duration.inMinutes.remainder(60));
    final s = twoDigits(duration.inSeconds.remainder(60));
    return "$h:$m:$s";
  }
}
