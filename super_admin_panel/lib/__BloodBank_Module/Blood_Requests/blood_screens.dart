import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_admin_panel/__BloodBank_Module/Donor_Lists/appbar_blood.dart';

class BloodRequestsScreen extends StatefulWidget {
  const BloodRequestsScreen({super.key});

  @override
  _BloodRequestsScreenState createState() => _BloodRequestsScreenState();
}

class _BloodRequestsScreenState extends State<BloodRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool enableWriteMode = true; // Control the visibility of the FAB

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomBloodAppBar(title: 'Blood Requests'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Blood_Requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              String status = request['request_status'];
              Color statusColor =
                  _getStatusColor(status); // Get color based on status

              return Column(
                children: [
                  ListTile(
                    title: Text(request['patient_name']),
                    subtitle: Text("Blood Type: ${request['blood_type']}"),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    onTap: () => _showDetailsDialog(request),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: enableWriteMode
          ? FloatingActionButton(
              onPressed: _addRequest,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Helper function to get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Fulfilled':
        return Colors.green;
      case 'Canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDetailsDialog(DocumentSnapshot request) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(request['patient_name']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Age: ${request['patient_age']}"),
                Text("Blood Type: ${request['blood_type']}"),
                Text("Units Required: ${request['units_required']}"),
                Text("Hospital: ${request['hospital_name']}"),
                Text("Address: ${request['hospital_address']}"),
                Text("Contact: ${request['contact_person']}"),
                Text("Phone: ${request['contact_number']}"),
                Text("Status: ${request['request_status']}"),
                Text("Date: ${request['request_date'].toDate().toString()}"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addRequest() async {
    final formKey = GlobalKey<FormState>();
    TextEditingController patientNameController = TextEditingController();
    TextEditingController patientAgeController = TextEditingController();
    TextEditingController unitsRequiredController = TextEditingController();
    TextEditingController hospitalNameController = TextEditingController();
    TextEditingController hospitalAddressController = TextEditingController();
    TextEditingController contactPersonController = TextEditingController();
    TextEditingController contactNumberController = TextEditingController();

    // List of blood types
    List<String> bloodTypes = [
      "A+",
      "A-",
      "B+",
      "B-",
      "O+",
      "O-",
      "AB+",
      "AB-"
    ];
    String selectedBloodType = bloodTypes[0]; // Default selected blood type

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Blood Request'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: patientNameController,
                    decoration:
                        const InputDecoration(labelText: 'Patient Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: patientAgeController,
                    decoration: const InputDecoration(labelText: 'Patient Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBloodType,
                    decoration: const InputDecoration(labelText: 'Blood Type'),
                    items: bloodTypes.map((String bloodType) {
                      return DropdownMenuItem<String>(
                        value: bloodType,
                        child: Text(bloodType),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBloodType = newValue!;
                      });
                    },
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: unitsRequiredController,
                    decoration:
                        const InputDecoration(labelText: 'Units Required'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: hospitalNameController,
                    decoration:
                        const InputDecoration(labelText: 'Hospital Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: hospitalAddressController,
                    decoration:
                        const InputDecoration(labelText: 'Hospital Address'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: contactPersonController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Person'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: contactNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Increment and get the new request ID
                    DocumentReference counterRef = _firestore
                        .collection('ID_Counters')
                        .doc('permanent_counters_skeleton');
                    DocumentSnapshot counterSnapshot = await counterRef.get();
                    int newRequestId = counterSnapshot['blood_req_counter'] + 1;
                    await counterRef
                        .update({'blood_req_counter': newRequestId});

                    // Add new request
                    await _firestore
                        .collection('Blood_Requests')
                        .doc(newRequestId.toString())
                        .set({
                      'request_id': newRequestId.toString(),
                      'patient_name': patientNameController.text,
                      'patient_age': int.parse(patientAgeController.text),
                      'blood_type': selectedBloodType,
                      'units_required': int.parse(unitsRequiredController.text),
                      'hospital_name': hospitalNameController.text,
                      'hospital_address': hospitalAddressController.text,
                      'contact_person': contactPersonController.text,
                      'contact_number': contactNumberController.text,
                      'request_status': 'Pending',
                      'request_date': Timestamp.now(),
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Request added successfully!')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add request: $e')));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
