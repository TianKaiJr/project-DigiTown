import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodPage extends StatefulWidget {
  const BloodPage({super.key});

  @override
  _BloodPageState createState() => _BloodPageState();
}

class _BloodPageState extends State<BloodPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _lastDonationDate;
  String _selectedBloodType = 'A+';
  List<String> bloodTypes = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

  void _addDonor() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('Blood_Donor_Lists').add({
          'name': _nameController.text,
          'age': int.parse(_ageController.text),
          'phone': _phoneController.text,
          'blood_type': _selectedBloodType,
          'last_donation_date': _lastDonationDate != null ? Timestamp.fromDate(_lastDonationDate!) : null,
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donor added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add donor: $e')),
        );
      }
    }
  }

  void _searchDonor() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Donor by Blood Type'),
          content: DropdownButtonFormField<String>(
            value: _selectedBloodType,
            items: bloodTypes.map((String bloodType) {
              return DropdownMenuItem<String>(
                value: bloodType,
                child: Text(bloodType),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedBloodType = newValue!;
              });
            },
          ),
          actions: [
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                Navigator.of(context).pop();
                _showDonorList(_selectedBloodType);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDonorList(String bloodType) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('Blood_Donor_Lists')
              .where('blood_type', isEqualTo: bloodType)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var donors = snapshot.data!.docs;
            return ListView.builder(
              itemCount: donors.length,
              itemBuilder: (context, index) {
                var donor = donors[index];
                return ListTile(
                  title: Text(donor['name']),
                  subtitle: Text("Phone: ${donor['phone']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () async {
                      final Uri phoneUri = Uri(scheme: 'tel', path: donor['phone']);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not launch phone call')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Blood Donor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: const InputDecoration(labelText: 'Blood Type'),
                items: bloodTypes.map((String bloodType) {
                  return DropdownMenuItem<String>(
                    value: bloodType,
                    child: Text(bloodType),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _lastDonationDate = pickedDate;
                    });
                  }
                },
                child: Text(_lastDonationDate == null
                    ? 'Select Last Donation Date'
                    : _lastDonationDate!.toLocal().toString().split(' ')[0]),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _addDonor,
                    child: const Text('Add Donor'),
                  ),
                  ElevatedButton(
                    onPressed: _searchDonor,
                    child: const Text('Search Donors'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}