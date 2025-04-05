import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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

  Map<String, String> _driverRequestStatus = {}; // driverId -> 'pending'
  Map<String, String> _requestDocumentIds = {}; // driverId -> Firestore docId

  @override
  void initState() {
    super.initState();
    _loadExistingRequests(); // Check Firestore for existing requests
  }

  Future<void> _loadExistingRequests() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? '';

    QuerySnapshot driversSnapshot =
        await FirebaseFirestore.instance.collection('Driver_Users').get();

    for (var driverDoc in driversSnapshot.docs) {
      final driverId = driverDoc.id;
      QuerySnapshot requests = await FirebaseFirestore.instance
          .collection('Driver_Users')
          .doc(driverId)
          .collection('Ride_Requests')
          .where('user_email', isEqualTo: userEmail)
          .where('completion_status', isEqualTo: false)
          .get();

      if (requests.docs.isNotEmpty) {
        _driverRequestStatus[driverId] = 'pending';
        _requestDocumentIds[driverId] = requests.docs.first.id;
      }
    }

    setState(() {}); // Refresh UI after loading
  }

  Future<void> _getUserLocation() async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _userPosition = position;
      _showBookNow = false;
    });

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
      double distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        driverLat,
        driverLng,
      );

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
    final Uri launchUri = Uri(scheme: 'tel', path: driver['phone']);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call ${driver['phone']}')),
      );
    }
  }

  Future<void> _sendLocationToDriver(Map<String, dynamic> driver) async {
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
              onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(
              child: const Text("Send"),
              onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (!confirm) return;

    try {
      DocumentReference ref = await FirebaseFirestore.instance
          .collection('Driver_Users')
          .doc(driver['id'])
          .collection('Ride_Requests')
          .add({
        'user_latitude': _userPosition!.latitude,
        'user_longitude': _userPosition!.longitude,
        'user_email': userEmail,
        'job_status': 'Pending',
        'completion_status': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _driverRequestStatus[driver['id']] = 'pending';
        _requestDocumentIds[driver['id']] = ref.id;
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

  void _discardRequest(String driverId) async {
    String? docId = _requestDocumentIds[driverId];
    if (docId != null) {
      await FirebaseFirestore.instance
          .collection('Driver_Users')
          .doc(driverId)
          .collection('Ride_Requests')
          .doc(docId)
          .delete();

      setState(() {
        _driverRequestStatus.remove(driverId);
        _requestDocumentIds.remove(driverId);
      });
    }
  }

  void _markAsDone(String driverId) async {
    String? docId = _requestDocumentIds[driverId];
    if (docId != null) {
      await FirebaseFirestore.instance
          .collection('Driver_Users')
          .doc(driverId)
          .collection('Ride_Requests')
          .doc(docId)
          .update({'completion_status': true});

      setState(() {
        _driverRequestStatus.remove(driverId);
        _requestDocumentIds.remove(driverId);
      });
    }
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
                    final driverId = driver['id'];
                    final requestStatus = _driverRequestStatus[driverId];

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
                            if (requestStatus == 'pending') ...[
                              ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: const Text('Sent'),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'discard') {
                                    _discardRequest(driverId);
                                  } else if (value == 'done') {
                                    _markAsDone(driverId);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'discard',
                                    child: Text('Discard'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'done',
                                    child: Text('Mark as Done'),
                                  ),
                                ],
                                child: const Icon(Icons.more_vert),
                              ),
                            ] else
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
}
