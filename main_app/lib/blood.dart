import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class BloodMainPage extends StatelessWidget {
  const BloodMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blood Donation'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Register as Donor"),
              Tab(text: "Put Request"),
              Tab(text: "My Requests"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddDonorTab(),
            PutRequestTab(),
            MyRequestsTab(),
          ],
        ),
      ),
    );
  }
}

// --------------- ADD DONOR ------------------

class AddDonorTab extends StatefulWidget {
  const AddDonorTab({super.key});

  @override
  State<AddDonorTab> createState() => _AddDonorTabState();
}

class _AddDonorTabState extends State<AddDonorTab> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _lastDonationDate;
  String _selectedBloodType = 'A+';

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<bool> _hasUserAlreadyRegistered(String email) async {
    var result = await _firestore
        .collection('Blood_Donor_Lists')
        .where('email', isEqualTo: email)
        .get();
    return result.docs.isNotEmpty;
  }

  void _addDonor() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("User not logged in");

        final alreadyRegistered = await _hasUserAlreadyRegistered(user.email!);
        if (alreadyRegistered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Oops!',
                message: 'Already registered as donor.',
                contentType:
                    ContentType.failure, // This sets red + error styling
              ),
            ),
          );
          return;
        }

        Position position = await _getCurrentLocation();

        await _firestore.collection('Blood_Donor_Lists').add({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'phone': _phoneController.text,
          'blood_type': _selectedBloodType,
          'last_donation_date': _lastDonationDate != null
              ? Timestamp.fromDate(_lastDonationDate!)
              : null,
          'email': user.email,
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Done👍👍',
              message: 'Donor added successfully!',
              contentType: ContentType.success, // This sets red + error styling
            ),
          ),
        );

        _nameController.clear();
        _ageController.clear();
        _phoneController.clear();
        _lastDonationDate = null;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add donor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter name' : null,
            ),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter age' : null,
            ),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter phone' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              onChanged: (val) => setState(() => _selectedBloodType = val!),
              decoration: const InputDecoration(labelText: 'Blood Type'),
              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _lastDonationDate == null
                        ? 'No date selected'
                        : 'Last Donation: ${_lastDonationDate!.toLocal()}'
                            .split(' ')[0],
                  ),
                ),
                TextButton(
                  child: const Text('Pick Date'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _lastDonationDate = picked);
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addDonor,
              child: const Text("Add Donor"),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------- PUT REQUEST ------------------

class PutRequestTab extends StatefulWidget {
  const PutRequestTab({super.key});

  @override
  State<PutRequestTab> createState() => _PutRequestTabState();
}

class _PutRequestTabState extends State<PutRequestTab> {
  final _nameController = TextEditingController();
  String _bloodGroup = 'A+';
  final _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> nearbyDonors = [];

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.0174533;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // km
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot launch phone call.")),
      );
    }
  }

  Future<void> _submitRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    await _firestore.collection("Blood_Requests").add({
      "patient_name": _nameController.text,
      "blood_group": _bloodGroup,
      "requested_by": user.email,
      "timestamp": Timestamp.now(),
      "status": "pending",
      "location": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
    });

    // Find nearby donors
    final donorSnapshot = await _firestore
        .collection("Blood_Donor_Lists")
        .where("blood_type", isEqualTo: _bloodGroup)
        .get();

    final nearby = donorSnapshot.docs
        .map((doc) {
          final loc = doc["location"];
          final dist = _calculateDistance(
            position.latitude,
            position.longitude,
            loc["latitude"],
            loc["longitude"],
          );
          return {
            'doc': doc,
            'distance': dist,
          };
        })
        .where((entry) =>
            entry['distance'] != null &&
            entry['distance'] is double &&
            (entry['distance'] as double) <= 10)
        .toList();

    setState(() {
      nearbyDonors = nearby;
    });

    _nameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Done👍👍',
          message: 'Request Sumitted.',
          contentType: ContentType.success, // This sets red + error styling
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Patient Name'),
        ),
        DropdownButtonFormField<String>(
          value: _bloodGroup,
          onChanged: (val) => setState(() => _bloodGroup = val!),
          decoration: const InputDecoration(labelText: 'Blood Group'),
          items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submitRequest,
          child: const Text("Submit Request"),
        ),
        const SizedBox(height: 24),
        if (nearbyDonors.isNotEmpty)
          const Text("Nearby Donors:",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ...nearbyDonors.map((entry) {
          final doc = entry['doc'];
          final distance = entry['distance'] as double;
          return ListTile(
            title: Text(doc["name"]),
            subtitle: Text(
                "Phone: ${doc["phone"]}\n${distance.toStringAsFixed(2)} km away"),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makePhoneCall(doc["phone"]),
            ),
            isThreeLine: true,
          );
        }),
      ],
    );
  }
}

// --------------- MY REQUESTS ------------------

class MyRequestsTab extends StatefulWidget {
  const MyRequestsTab({super.key});

  @override
  State<MyRequestsTab> createState() => _MyRequestsTabState();
}

class _MyRequestsTabState extends State<MyRequestsTab> {
  late Future<String?> _userEmailFuture;

  Future<String?> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  @override
  void initState() {
    super.initState();
    _userEmailFuture = _fetchUserEmail();
  }

  Future<void> _showDonorDialog(String requestId, String bloodGroup) async {
    String? selectedDonorId;

    final donorsSnapshot = await FirebaseFirestore.instance
        .collection("Blood_Donor_Lists")
        .where("blood_type", isEqualTo: bloodGroup)
        .get();

    final donors = donorsSnapshot.docs;

    if (donors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: AwesomeSnackbarContent(
            title: "No Match",
            message: "No donors found with blood group $bloodGroup.",
            contentType: ContentType.warning,
          ),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Donor"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                isExpanded: true,
                value: selectedDonorId,
                hint: const Text("Choose donor"),
                items: donors.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(doc["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDonorId = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedDonorId == null) return;

                // 1. Mark request as completed
                await FirebaseFirestore.instance
                    .collection("Blood_Requests")
                    .doc(requestId)
                    .update({"status": "completed"});

                // 2. Update donor's last donation date
                await FirebaseFirestore.instance
                    .collection("Blood_Donor_Lists")
                    .doc(selectedDonorId)
                    .update({
                  "last_donation_date": Timestamp.now(),
                });

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    content: AwesomeSnackbarContent(
                      title: "Success",
                      message: "Request marked as completed.",
                      contentType: ContentType.success,
                    ),
                  ),
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _userEmailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("User not logged in."));
        }

        final userEmail = snapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Blood_Requests")
              .where("requested_by", isEqualTo: userEmail)
              .snapshots(),
          builder: (context, requestSnapshot) {
            if (requestSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!requestSnapshot.hasData ||
                requestSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No requests yet."));
            }

            final docs = requestSnapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final status = doc["status"];
                final docId = doc.id;
                final bloodGroup = doc["blood_group"];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text("Patient: ${doc["patient_name"]}"),
                    subtitle: Text(
                      "Blood Group: $bloodGroup\nStatus: $status",
                    ),
                    isThreeLine: true,
                    trailing: status != "completed"
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            onPressed: () =>
                                _showDonorDialog(docId, bloodGroup),
                            child: const Text("Complete",
                                style: TextStyle(fontSize: 12)),
                          )
                        : const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
