import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class DoctorCRUDScreen extends StatefulWidget {
  const DoctorCRUDScreen({super.key});

  @override
  _DoctorCRUDScreenState createState() => _DoctorCRUDScreenState();
}

class _DoctorCRUDScreenState extends State<DoctorCRUDScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showDoctorDialog({DocumentSnapshot? doc}) {
    final TextEditingController nameController =
        TextEditingController(text: doc?['Name'] ?? '');
    final TextEditingController specializationController =
        TextEditingController(text: doc?['Specialization'] ?? '');

    String? selectedDepartment = doc?['Department'];
    DocumentReference? selectedHospital = doc?['Hospital'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(doc == null ? 'Add Doctor' : 'Edit Doctor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: specializationController,
                  decoration:
                      const InputDecoration(labelText: 'Specialization')),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore.collection('Hospital_Departments').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  var departments = snapshot.data!.docs
                      .map((doc) => doc['name'].toString())
                      .toList();
                  return DropdownButtonFormField<String>(
                    value: selectedDepartment,
                    onChanged: (value) =>
                        setState(() => selectedDepartment = value),
                    items: departments
                        .map((dep) =>
                            DropdownMenuItem(value: dep, child: Text(dep)))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Department'),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Hospitals').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  var hospitals = snapshot.data!.docs;
                  return DropdownButtonFormField<DocumentReference>(
                    value: selectedHospital,
                    onChanged: (value) =>
                        setState(() => selectedHospital = value),
                    items: hospitals
                        .map((doc) => DropdownMenuItem(
                              value: doc.reference,
                              child: Text(doc['Name']),
                            ))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Hospital'),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    specializationController.text.isEmpty ||
                    selectedDepartment == null ||
                    selectedHospital == null) {
                  return;
                }
                if (doc == null) {
                  await _firestore.collection('Doctors').add({
                    'Name': nameController.text,
                    'Specialization': specializationController.text,
                    'Department': selectedDepartment,
                    'Hospital': selectedHospital,
                    'status': 'Leave',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                } else {
                  await doc.reference.update({
                    'Name': nameController.text,
                    'Specialization': specializationController.text,
                    'Department': selectedDepartment,
                    'Hospital': selectedHospital,
                    'status': 'Leave',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Doctor Management'),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Doctors').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var doctors = snapshot.data!.docs;
          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              var doc = doctors[index];
              return ListTile(
                title: Text(doc['Name']),
                subtitle: Text(doc['Specialization']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showDoctorDialog(doc: doc);
                    } else if (value == 'delete') {
                      doc.reference.delete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () => _showDoctorDialog(doc: doc),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDoctorDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
