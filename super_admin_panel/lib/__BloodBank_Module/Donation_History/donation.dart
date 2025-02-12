import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodDonationHistoryScreen extends StatelessWidget {
  const BloodDonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blood_Donation_History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Blood_Donation_History')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Donation Records Found"));
          }

          final donations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text("Donor ID: ${donation['donor_id']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Blood Type: ${donation['blood_type']}"),
                      Text("Units Donated: ${donation['units_donated']}"),
                      Text("Hospital: ${donation['hospital_name']}"),
                      Text("Verified: ${donation['verified'] ? "Yes" : "No"}"),
                    ],
                  ),
                  trailing: Text(
                    (donation['donation_date'] as Timestamp)
                        .toDate()
                        .toString()
                        .split(" ")[0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
