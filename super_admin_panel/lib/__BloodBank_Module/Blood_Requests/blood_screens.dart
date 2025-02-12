import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_admin_panel/__BloodBank_Module/Donor_Lists/appbar_blood.dart';

class BloodRequestsScreen extends StatefulWidget {
  final bool enableWriteMode;

  const BloodRequestsScreen({super.key, this.enableWriteMode = false});

  @override
  State<BloodRequestsScreen> createState() => _BloodRequestsScreenState();
}

class _BloodRequestsScreenState extends State<BloodRequestsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _hospitalAddressController =
      TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  String _requestStatus = "Pending"; // Default status

  void _submitRequest() async {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _bloodTypeController.text.isEmpty ||
        _unitsController.text.isEmpty ||
        _hospitalNameController.text.isEmpty ||
        _hospitalAddressController.text.isEmpty ||
        _contactPersonController.text.isEmpty ||
        _contactNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('Blood_Requests').add({
      "patient_name": _nameController.text,
      "patient_age": int.parse(_ageController.text),
      "blood_type": _bloodTypeController.text,
      "units_required": int.parse(_unitsController.text),
      "hospital_name": _hospitalNameController.text,
      "hospital_address": _hospitalAddressController.text,
      "contact_person": _contactPersonController.text,
      "contact_number": _contactNumberController.text,
      "request_status": _requestStatus,
      "request_date": Timestamp.now(),
    });

    Navigator.of(context).pop(); // Close the dialog
    _clearFields();
  }

  void _clearFields() {
    _nameController.clear();
    _ageController.clear();
    _bloodTypeController.clear();
    _unitsController.clear();
    _hospitalNameController.clear();
    _hospitalAddressController.clear();
    _contactPersonController.clear();
    _contactNumberController.clear();
    _requestStatus = "Pending";
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request['patient_name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Age: ${request['patient_age']}"),
            Text("Blood Type: ${request['blood_type']}"),
            Text("Units Required: ${request['units_required']}"),
            Text("Hospital: ${request['hospital_name']}"),
            Text("Address: ${request['hospital_address']}"),
            Text(
                "Contact: ${request['contact_person']} (${request['contact_number']})"),
            Text(
              "Status: ${request['request_status']}",
              style: TextStyle(
                color: request['request_status'] == "Pending"
                    ? Colors.orange
                    : request['request_status'] == "Fulfilled"
                        ? Colors.green
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Date: ${(request['request_date'] as Timestamp).toDate().toString().split(" ")[0]}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAddRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Blood Request"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Patient Name")),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: "Patient Age"),
                  keyboardType: TextInputType.number),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: _bloodTypeController,
                  decoration: const InputDecoration(labelText: "Blood Type")),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: _unitsController,
                  decoration:
                      const InputDecoration(labelText: "Units Required"),
                  keyboardType: TextInputType.number),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: _hospitalNameController,
                  decoration:
                      const InputDecoration(labelText: "Hospital Name")),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: _hospitalAddressController,
                  decoration:
                      const InputDecoration(labelText: "Hospital Address")),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: _contactPersonController,
                  decoration:
                      const InputDecoration(labelText: "Contact Person")),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: _contactNumberController,
                  decoration:
                      const InputDecoration(labelText: "Contact Number"),
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _requestStatus,
                decoration: const InputDecoration(labelText: "Request Status"),
                items: ["Pending", "Fulfilled", "Canceled"].map((status) {
                  return DropdownMenuItem<String>(
                      value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _requestStatus = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: _submitRequest, child: const Text("Submit")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomBloodAppBar(title: "Blood Requests"),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('Blood_Requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Blood Requests Found"));
          }

          final requests = snapshot.data!.docs;

          return ListView.separated(
            itemCount: requests.length,
            separatorBuilder: (context, index) =>
                const Divider(thickness: 1, height: 1),
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(request['patient_name'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Blood Type: ${request['blood_type']}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      request['request_status'],
                      style: TextStyle(
                        color: request['request_status'] == "Pending"
                            ? Colors.orange
                            : request['request_status'] == "Fulfilled"
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showRequestDetails(request),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.enableWriteMode
          ? FloatingActionButton(
              onPressed: _showAddRequestDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
