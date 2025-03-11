import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class TaxiServiceScreen extends StatefulWidget {
  const TaxiServiceScreen({super.key});

  @override
  _TaxiServiceScreenState createState() => _TaxiServiceScreenState();
}

class _TaxiServiceScreenState extends State<TaxiServiceScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Future<void> _getCurrentLocation() async {
  //   LocationPermission permission = await Geolocator.requestPermission();
  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     return;
  //   }
  //   Position position = await Geolocator.getCurrentPosition( 
  //       desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _currentPosition = position;
  //   });
  // }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _currentPosition = Position(
        latitude: 10.170680,
        longitude: 76.429475,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
        speedAccuracy: 0,
        timestamp: DateTime.now(),
      );
    });
  }

  double _calculateDistance(double lat, double lon) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
            _currentPosition!.latitude, _currentPosition!.longitude, lat, lon) /
        1000; // Convert meters to kilometers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Taxi Service'),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('Driver_Users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No drivers available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var driver = snapshot.data!.docs[index];
              String name = driver['name'];
              String phone = driver['phone'];
              double latitude = driver['latitude'];
              double longitude = driver['longitude'];
              String available = driver['available'];
              double distance = _calculateDistance(latitude, longitude);

              return Column(
                children: [
                  ListTile(
                    title: Text(name),
                    subtitle: Text(phone),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${distance.toStringAsFixed(2)} km'),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.circle,
                          color: available.toLowerCase() == 'yes'
                              ? Colors.green
                              : Colors.red,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
