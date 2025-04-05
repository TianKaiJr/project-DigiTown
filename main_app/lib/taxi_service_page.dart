import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // for current user email
import 'package:url_launcher/url_launcher.dart';
import 'NoInternetComponent/Utils/network_utils.dart';

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

  void _bookDriver(Map<String, dynamic> driver) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: driver['phone'],
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call ${driver['phone']}')),
      );
    }
  }

  void _sendLocationToDriver(Map<String, dynamic> driver) async {
    if (_userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User location not available")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'unknown';

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Location"),
        content: const Text(
            "Are you sure you want to send your location to this driver?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Send"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (!confirm) return;

    try {
      await FirebaseFirestore.instance
          .collection('Driver_Users')
          .doc(driver['id'])
          .collection('Ride_Requests')
          .add({
        'user_latitude': _userPosition!.latitude,
        'user_longitude': _userPosition!.longitude,
        'user_email': userEmail,
        'job_status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location sent successfully")),
      );
    } catch (e) {
      print("Error sending location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send location")),
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
                        trailing: Wrap(
                          spacing: 10,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                NetworkUtils.checkAndProceed(context, () {
                                  _bookDriver(driver);
                                });
                              },
                              child: const Text('Call Now'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                NetworkUtils.checkAndProceed(context, () {
                                  _sendLocationToDriver(driver);
                                });
                              },
                              child: const Text('Send Location'),
                            ),
                          ],
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
