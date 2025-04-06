import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class BloodRequestsScreen extends StatelessWidget {
  const BloodRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ("Blood Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection("Blood_Requests").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final name = doc["patient_name"];
              final bloodGroup = doc["blood_group"];
              final status = doc["status"];
              final isCompleted = status == "completed";

              return ListTile(
                title: Text("Patient: $name"),
                subtitle: Text("Blood Group: $bloodGroup"),
                trailing: Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: isCompleted ? Colors.green : Colors.orange,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
