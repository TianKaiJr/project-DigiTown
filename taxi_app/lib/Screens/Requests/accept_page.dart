import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedTaskPage extends StatelessWidget {
  final String driverId;

  const AcceptedTaskPage({super.key, required this.driverId});

  Future<void> _navigateToUser(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");

    final bool launched = await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw 'Could not open the map.';
    }
  }

  Future<String> _getUserNameByEmail(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['name'] ?? 'No Name';
    } else {
      return 'Unknown User';
    }
  }

  Future<void> _rejectTask(String docId) async {
    await FirebaseFirestore.instance
        .collection('Driver_Users')
        .doc(driverId)
        .collection('Ride_Requests')
        .doc(docId)
        .update({'job_status': 'Rejected', 'completion_status': true});
  }

  @override
  Widget build(BuildContext context) {
    final acceptedRef = FirebaseFirestore.instance
        .collection('Driver_Users')
        .doc(driverId)
        .collection('Ride_Requests')
        .where('job_status', isEqualTo: 'Accepted');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Task'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: acceptedRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final accepted = snapshot.data?.docs ?? [];

          if (accepted.isEmpty) {
            return const Center(child: Text("No current task"));
          }

          final doc = accepted.first;
          final task = doc.data() as Map<String, dynamic>;
          final docId = doc.id;

          final String userEmail = task['user_email'] ?? 'N/A';
          final double? lat = (task['user_latitude'] as num?)?.toDouble();
          final double? lng = (task['user_longitude'] as num?)?.toDouble();

          if (lat == null || lng == null) {
            return const Center(child: Text("Invalid location data"));
          }

          return FutureBuilder<String>(
            future: _getUserNameByEmail(userEmail),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final String userName = userSnapshot.data ?? 'Unknown';

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Name: $userName',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text('Location: $lat, $lng'),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToUser(lat, lng),
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _rejectTask(docId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task Rejected')),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Reject Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
