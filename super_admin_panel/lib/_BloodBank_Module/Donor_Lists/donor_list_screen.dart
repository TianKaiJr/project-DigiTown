import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class DonorListScreen extends StatelessWidget {
  const DonorListScreen({super.key});

  final String apiKey =
      'AIzaSyA70uOlfF8qiYa1RzyKvxOyN42HVBB-iwQ'; // 🔑 Replace with your key

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else {
          return "Geocoding error: ${data['status']}";
        }
      } else {
        return "Error: HTTP ${response.statusCode}";
      }
    } catch (e) {
      return "Exception: $e";
    }
  }

  int _weeksSinceLastDonation(Timestamp timestamp) {
    final lastDate = timestamp.toDate();
    return DateTime.now().difference(lastDate).inDays ~/ 7;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Registered Donors"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Blood_Donor_Lists")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final donor = docs[index];
              final name = donor["name"];
              final bloodGroup = donor["blood_type"];
              final lastDonationTimestamp = donor["last_donation_date"];
              final lat = donor["location"]["latitude"];
              final lng = donor["location"]["longitude"];
              final weeks = _weeksSinceLastDonation(lastDonationTimestamp);

              return FutureBuilder<String>(
                future: _getAddressFromCoordinates(lat, lng),
                builder: (context, addressSnap) {
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text("$name ($bloodGroup)"),
                    subtitle: Text(
                      "Weeks since donation: $weeks\nLocation: ${addressSnap.data ?? "Loading..."}",
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
