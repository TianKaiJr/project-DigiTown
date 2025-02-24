import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class TaxiServicePage extends StatefulWidget {
  const TaxiServicePage({super.key});

  @override
  _TaxiServicePageState createState() => _TaxiServicePageState();
}

class _TaxiServicePageState extends State<TaxiServicePage> {
  Position? _userPosition;
  Timer? _locationTimer;

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userPosition = position;
    });

    // Print user location with high precision (7 decimal places)
    print('User Location: Lat: ${position.latitude.toStringAsFixed(7)}, Lng: ${position.longitude.toStringAsFixed(7)}, Accuracy: ${position.accuracy}m');
    
    _findNearestAvailableDriver();
  }

  Future<void> _findNearestAvailableDriver() async {
    if (_userPosition == null) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Driver_Users')
        .where('available', isEqualTo: 'yes')
        .get();

    if (querySnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available drivers found')),
      );
      return;
    }

    var nearestDriver;
    double shortestDistance = double.infinity;

    for (var doc in querySnapshot.docs) {
      double driverLat = doc['latitude'];
      double driverLng = doc['longitude'];
      double distance = Geolocator.distanceBetween(
          _userPosition!.latitude, _userPosition!.longitude, driverLat, driverLng);

      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestDriver = doc;
      }
    }

    if (nearestDriver != null) {
      _showDriverDetails(nearestDriver);
    }
  }

  void _showDriverDetails(QueryDocumentSnapshot driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nearest Available Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Driver: ${driver['name']}'),
            Text('Phone: ${driver['phone']}'),
            Text('Distance: ${Geolocator.distanceBetween(
              _userPosition!.latitude, _userPosition!.longitude,
              driver['latitude'], driver['longitude'],
            ).toStringAsFixed(2)} meters'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _startLocationUpdates() async {
    await _getUserLocation(); // Fetch location immediately
    _locationTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      await _getUserLocation();
    });
  }

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

  Future<void> _fetchLocation() async {
    try {
      bool permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Location: Lat: ${position.latitude.toStringAsFixed(7)}, Long: ${position.longitude.toStringAsFixed(7)}');
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxi Service'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Taxi Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getUserLocation,
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}