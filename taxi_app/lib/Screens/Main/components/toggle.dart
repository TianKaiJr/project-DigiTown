import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ToggleButton extends StatefulWidget {
  final String userId; // User's Firestore document ID

  const ToggleButton({super.key, required this.userId});

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
        await _updateAvailability(true);
        await _startLocationUpdates();
      } else {
        print('Toggle is: OFF');
        await _updateAvailability(false);
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

  // Function to update the 'available' field in Firestore
  Future<void> _updateAvailability(bool isAvailable) async {
    try {
      await FirebaseFirestore.instance
          .collection('Driver_Users')
          .doc(widget.userId)
          .update({'available': isAvailable ? 'yes' : 'no'});
    } catch (e) {
      print('Error updating availability: $e');
    }
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

  // Function to fetch the current location and store it in Firestore
  Future<void> _fetchLocation() async {
    try {
      bool permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Location: Lat: ${position.latitude}, Long: ${position.longitude}');

      // Store location in Firestore under "Driver_Users" collection
      await FirebaseFirestore.instance
          .collection('Driver_Users')
          .doc(widget.userId)
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  // Function to start periodic location updates
  Future<void> _startLocationUpdates() async {
    await _fetchLocation(); // Fetch location immediately
    _locationTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
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
