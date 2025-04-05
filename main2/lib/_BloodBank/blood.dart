import 'package:flutter/material.dart';
import 'package:main2/__Utils/NoNetwork/network_utils.dart';

class BloodPage extends StatelessWidget {
  const BloodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blood Bank"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome to the Blood Bank page.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterBloodDonation()),
                );
              },
              child: const Text("Register to Donate Blood"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestBlood()),
                );
              },
              child: const Text("Request for Blood"),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterBloodDonation extends StatefulWidget {
  const RegisterBloodDonation({super.key});

  @override
  _RegisterBloodDonationState createState() => _RegisterBloodDonationState();
}

class _RegisterBloodDonationState extends State<RegisterBloodDonation> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController();

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thank You for Registering to Donate Blood!"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text("Please review the details you have provided:\n"),
              Text("Name: ${nameController.text}"),
              Text("Age: ${ageController.text}"),
              Text("Gender: ${genderController.text}"),
              Text("Blood Group: ${bloodGroupController.text}"),
              Text("Contact Information: ${contactController.text}"),
              Text(
                  "Medical History: ${medicalHistoryController.text.isNotEmpty ? medicalHistoryController.text : 'Not Provided'}"),
              const SizedBox(height: 20),
              const Text("By clicking Agree, you confirm the following:\n"),
              const Text(
                  "- I am voluntarily registering to donate blood without any coercion or monetary compensation."),
              const Text(
                  "- I have provided accurate and truthful information about my health and medical history."),
              const Text(
                  "- I understand the process of blood donation, its potential risks, and benefits."),
              const Text(
                  "- I consent to my blood being tested for infectious diseases (e.g., HIV, Hepatitis B & C, syphilis, malaria) and understand that the results will remain confidential."),
              const Text(
                  "- I am aware that I can withdraw my consent at any time before the donation process begins."),
              const Text(
                  "- I understand that my donated blood will be used for life-saving purposes in compliance with applicable laws and guidelines."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("You have declined to register.")),
              );
            },
            child: const Text("Decline"),
          ),
          TextButton(
            onPressed: () {
              NetworkUtils.checkAndProceed(context, () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text("Thank you for registering to donate blood!")),
                );
                // Add logic for final submission to backend or database here
              });
            },
            child: const Text("Agree"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register to Donate Blood"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Fill in your details to register:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: genderController,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: bloodGroupController,
              decoration: const InputDecoration(
                labelText: "Blood Group",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(
                labelText: "Contact Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: medicalHistoryController,
              decoration: const InputDecoration(
                labelText: "Medical History (if any)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NetworkUtils.checkAndProceed(context, _showConfirmationDialog);
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestBlood extends StatefulWidget {
  const RequestBlood({super.key});

  @override
  _RequestBloodState createState() => _RequestBloodState();
}

class _RequestBloodState extends State<RequestBlood> {
  final _nameController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _urgencyController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _donorList = [
    {
      'name': 'John Doe',
      'bloodGroup': 'A+',
      'phone': '+1234567890',
      'location': 'Location 1'
    },
    {
      'name': 'Jane Smith',
      'bloodGroup': 'B+',
      'phone': '+19876543210',
      'location': 'Location 2'
    },
    {
      'name': 'Mike Johnson',
      'bloodGroup': 'O-',
      'phone': '+15551234567',
      'location': 'Location 3'
    },
    {
      'name': 'Emily Davis',
      'bloodGroup': 'AB+',
      'phone': '+14447891234',
      'location': 'Location 4'
    },
  ];

  List<Map<String, String>> _matchedDonors = [];

  @override
  void dispose() {
    _nameController.dispose();
    _bloodGroupController.dispose();
    _urgencyController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Blood compatibility mapping
  final Map<String, List<String>> compatibility = {
    'A+': ['A+', 'AB+'],
    'A-': ['A+', 'A-', 'AB+', 'AB-'],
    'B+': ['B+', 'AB+'],
    'B-': ['B+', 'B-', 'AB+', 'AB-'],
    'O+': ['O+', 'A+', 'B+', 'AB+'],
    'O-': ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'],
    'AB+': ['AB+'],
    'AB-': ['AB+', 'AB-'],
  };

  // Function to check blood compatibility
  List<Map<String, String>> _findMatchingDonors(String bloodGroup) {
    List<Map<String, String>> matchedDonors = [];
    for (var donor in _donorList) {
      if (compatibility[bloodGroup]?.contains(donor['bloodGroup']) ?? false) {
        matchedDonors.add(donor);
      }
    }
    return matchedDonors;
  }

  // Simulate search logic based on blood group and location
  void _searchDonors() {
    setState(() {
      _matchedDonors = _findMatchingDonors(_bloodGroupController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request for Blood"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Blood group input
            TextField(
              controller: _bloodGroupController,
              decoration: const InputDecoration(
                labelText: "Blood Group Required",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Urgency input
            TextField(
              controller: _urgencyController,
              decoration: const InputDecoration(
                labelText: "Urgency (e.g., Immediate, Within a Day)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Contact input
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: "Contact Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Address input
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Search button
            ElevatedButton(
              onPressed: () {
                NetworkUtils.checkAndProceed(context, _searchDonors);
              },
              child: const Text("Search Donors"),
            ),

            const SizedBox(height: 16),

            // Display matched donors
            if (_matchedDonors.isNotEmpty)
              ..._matchedDonors.map((donor) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    title: Text(donor['name']!),
                    subtitle: Text(
                        "Blood Group: ${donor['bloodGroup']}\nLocation: ${donor['location']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {
                            // Handle call action
                            _makeCall(donor['phone']!);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            // Handle message action
                            _sendMessage(donor['phone']!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              })
            else
              const Text('No matching donors found.'),
          ],
        ),
      ),
    );
  }

  // Placeholder function for making a call
  void _makeCall(String phoneNumber) {
    print("Calling $phoneNumber...");
  }

  // Placeholder function for sending a message
  void _sendMessage(String phoneNumber) {
    print("Sending message to $phoneNumber...");
  }
}
