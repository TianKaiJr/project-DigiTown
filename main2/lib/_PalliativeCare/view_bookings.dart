import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewBookingsPage extends StatelessWidget {
  const ViewBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Bookings"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId',
                isEqualTo: userId) // Fetch only the current user's bookings
            .orderBy('timestamp', descending: true) // Latest first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['service'] ?? 'Unknown Service'),
                  subtitle: Text("Requested on: ${data['date'] ?? 'N/A'}"),
                  trailing: _getStatusWidget(data['status']),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _getStatusWidget(String? status) {
    Color statusColor;
    switch (status) {
      case "Approved":
        statusColor = Colors.blue;
        break;
      case "Completed":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        status ?? "Pending",
        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
