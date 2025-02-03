import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key});

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  final _controller = ValueNotifier<bool>(false);
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() async {
      if (_controller.value) {
        print('Toggle is: ON');
        await _startLocationUpdates();
      } else {
        print('Toggle is: OFF');
        _stopLocationUpdates();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  // Function to handle location permissions
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return false;
    }

    return true;
  }

  // Function to fetch the current location
  Future<void> _fetchLocation() async {
    try {
      bool permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Location: Lat: ${position.latitude}, Long: ${position.longitude}');
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  // Function to start periodic location updates
  Future<void> _startLocationUpdates() async {
    await _fetchLocation(); // Fetch the location immediately
    _locationTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      await _fetchLocation();
    });
  }

  // Function to stop periodic location updates
  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedSwitch(
      controller: _controller,
      activeColor: Colors.green,
      inactiveColor: Colors.red,
      activeChild: Text(
        'ON',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      inactiveChild: Text(
        'OFF',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      borderRadius: BorderRadius.circular(20),
      width: 120,
      height: 60,
    );
  }
}
