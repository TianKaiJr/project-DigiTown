import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequestsPage extends StatelessWidget {
  final String driverId;

  const RideRequestsPage({super.key, required this.driverId});

  /// Check if the driver already has an accepted and incomplete task
  Future<bool> _hasActiveTask() async {
    final query = await FirebaseFirestore.instance
        .collection('Driver_Users')
        .doc(driverId)
        .collection('Ride_Requests')
        .where('task_accept', isEqualTo: true)
        .where('completion_status', isEqualTo: false)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// Accept a ride request
  Future<void> _acceptRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('Driver_Users')
        .doc(driverId)
        .collection('Ride_Requests')
        .doc(requestId)
        .update({
      'job_status': 'Accepted',
      'task_accept': true,
      'completion_status': false,
    });
  }

  /// Reject a ride request
  Future<void> _rejectRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('Driver_Users')
        .doc(driverId)
        .collection('Ride_Requests')
        .doc(requestId)
        .update({
      'job_status': 'Rejected',
      'task_accept': false,
      'completion_status': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestsRef = FirebaseFirestore.instance
        .collection('Driver_Users')
        .doc(driverId)
        .collection('Ride_Requests')
        .where('job_status', isEqualTo: 'Pending');

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No ride requests available."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('User: ${data['user_email']}'),
                  subtitle: Text(
                      'Lat: ${data['user_latitude']}, Lng: ${data['user_longitude']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Accept',
                        onPressed: () async {
                          final hasTask = await _hasActiveTask();
                          if (hasTask) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("You already have an active task."),
                              ),
                            );
                          } else {
                            await _acceptRequest(docId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Request Accepted."),
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Reject',
                        onPressed: () async {
                          await _rejectRequest(docId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Request Rejected."),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
