import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ToggleButton extends StatefulWidget {
  final String userId;

  const ToggleButton({super.key, required this.userId});

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton>
    with WidgetsBindingObserver {
  bool isOn = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadToggleState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationUpdates(); // Stop updates when widget is disposed
    super.dispose();
  }

  // Load toggle state from SharedPreferences
  Future<void> _loadToggleState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isOn = prefs.getBool('isOn') ?? false;
    });

    if (isOn) {
      _startLocationUpdates();
    }
  }

  // Save toggle state to SharedPreferences
  Future<void> _saveToggleState(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOn', state);
  }

  // Update Firestore availability
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

  // Handle location permissions
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

  // Fetch and update location in Firestore
  Future<void> _fetchLocation() async {
    try {
      bool permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) {
        await FirebaseFirestore.instance
            .collection('Driver_Users')
            .doc(widget.userId)
            .update({
          'latitude': 10.192659,
          'longitude': 76.386865,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Location: Lat: ${position.latitude}, Long: ${position.longitude}');

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

  // Start periodic location updates
  Future<void> _startLocationUpdates() async {
    if (_locationTimer != null && _locationTimer!.isActive) return;

    await _fetchLocation();
    _locationTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!isOn) {
        _stopLocationUpdates();
        return;
      }
      await _fetchLocation();
    });
  }

  // Stop location updates
  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      if (isOn) {
        setState(() {
          isOn = false;
        });
        _updateAvailability(false);
        _stopLocationUpdates();
        _saveToggleState(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GPSButton(
      isOn: isOn,
      onTap: () async {
        setState(() {
          isOn = !isOn;
        });

        if (isOn) {
          print('Toggle is: ON');
          await _updateAvailability(true);
          await _saveToggleState(true);
          await _startLocationUpdates();
        } else {
          print('Toggle is: OFF');
          await _updateAvailability(false);
          _stopLocationUpdates();
          await _saveToggleState(false);
        }
      },
    );
  }
}

class GPSButton extends StatelessWidget {
  final bool isOn;
  final VoidCallback onTap;

  const GPSButton({super.key, required this.isOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn ? Colors.green : Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.power_settings_new,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
