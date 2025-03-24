import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:main2/__Utils/NoNetwork/network_utils.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class TaxiServicePage extends StatefulWidget {
  const TaxiServicePage({super.key});

  @override
  _TaxiServicePageState createState() => _TaxiServicePageState();
}

class _TaxiServicePageState extends State<TaxiServicePage> {
  Position? _userPosition;
  List<Map<String, dynamic>> _availableDrivers = [];
  bool _hasSearched = false;
  bool _showBookNow = true;

  Future<void> _getUserLocation() async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _userPosition = position;
      _showBookNow = false;
    });

    print('User Location: Lat: ${position.latitude.toStringAsFixed(7)}, '
        'Lng: ${position.longitude.toStringAsFixed(7)}, Accuracy: ${position.accuracy}m');

    _findNearestAvailableDrivers();
  }

  Future<void> _findNearestAvailableDrivers() async {
    if (_userPosition == null) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Driver_Users')
        .where('available', isEqualTo: 'yes')
        .get();

    List<Map<String, dynamic>> drivers = [];

    for (var doc in querySnapshot.docs) {
      double driverLat = doc['latitude'];
      double driverLng = doc['longitude'];
      double distance = Geolocator.distanceBetween(_userPosition!.latitude,
          _userPosition!.longitude, driverLat, driverLng);

      drivers.add({
        'id': doc.id,
        'name': doc['name'],
        'phone': doc['phone'],
        'latitude': driverLat,
        'longitude': driverLng,
        'distance': distance,
      });
    }

    drivers.sort((a, b) => a['distance'].compareTo(b['distance']));

    setState(() {
      _availableDrivers = drivers;
      _hasSearched = true;
    });
  }

  // REPLACE THE OLD BOOKING LOGIC WITH A PHONE CALL
  void _bookDriver(Map<String, dynamic> driver) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: driver['phone'],
    );
    // Attempt to launch the dialer
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call ${driver['phone']}')),
      );
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
            if (_showBookNow)
              ElevatedButton(
                onPressed: () {
                  NetworkUtils.checkAndProceed(context, () {
                    _getUserLocation();
                  });
                },
                child: const Text('Book Now'),
              ),
            const SizedBox(height: 20),
            if (_hasSearched && _availableDrivers.isEmpty)
              const Text('No drivers found'),
            if (_availableDrivers.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _availableDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = _availableDrivers[index];
                    return Card(
                      child: ListTile(
                        title: Text(driver['name']),
                        subtitle: Text(
                          'Phone: ${driver['phone']}\nDistance: ${driver['distance'].toStringAsFixed(2)} meters',
                        ),
                        // CHANGED "Book" TO "Call Now"
                        trailing: ElevatedButton(
                          onPressed: () {
                            NetworkUtils.checkAndProceed(context, () {
                              _bookDriver(driver);
                            });
                          },
                          child: const Text('Call Now'),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return false;
    }

    return true;
  }
}
