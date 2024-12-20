import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:super_admin_panel/ZTemporary/constants.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  void _addOrEditDoctor(
      {String? docId, String? currentName, String? currentDesignation}) {
    final String formattedTimestamp =
        DateFormat('yyyy MM dd HH:mm').format(DateTime.now());
    // Pre-fill text fields if editing
    if (docId != null) {
      _nameController.text = currentName ?? '';
      _designationController.text = currentDesignation ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? "Add Doctor" : "Edit Doctor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _designationController,
                decoration: const InputDecoration(labelText: "Designation"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _nameController.clear();
                _designationController.clear();
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _designationController.text.isNotEmpty) {
                  try {
                    if (docId == null) {
                      // Add new doctor
                      await _firestore
                          .collection('Doctors_Attendence')
                          .doc(_nameController.text)
                          .set({
                        'name': _nameController.text,
                        'designation': _designationController.text,
                        'status': 'Available',
                        'timestamp': formattedTimestamp,
                      });
                    } else {
                      // Edit existing doctor
                      await _firestore
                          .collection('Doctors_Attendence')
                          .doc(docId)
                          .update({
                        'name': _nameController.text,
                        'designation': _designationController.text,
                        'timestamp': formattedTimestamp,
                      });
                    }

                    _nameController.clear();
                    _designationController.clear();
                    Navigator.of(context).pop();
                  } catch (e) {
                    print("Error: $e");
                  }
                }
              },
              child: Text(docId == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteDoctor(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Doctor"),
          content: const Text("Are you sure you want to delete this doctor?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore
                      .collection('Doctors_Attendence')
                      .doc(docId)
                      .delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error: $e");
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _toggleAvailability(String docId, bool isAvailable) async {
    final String formattedTimestamp =
        DateFormat('yyyy MM dd HH:mm').format(DateTime.now());
    await _firestore.collection('Doctors_Attendence').doc(docId).update({
      'status': isAvailable ? 'Available' : 'Leave',
      'timestamp': formattedTimestamp,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40), // Adjust height as needed
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
          child: AppBar(
            title: Text(
                "Live Attendance (${DateFormat('yMMMMd').format(DateTime.now())})"),
            centerTitle: true,
            elevation: 5,
            backgroundColor: bgColor, // Custom color
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditDoctor(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Doctors_Attendence').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No doctors registered yet."),
            );
          }

          final doctors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              final docId = doc.id;
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 5,
                child: ListTile(
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(data['designation'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Available"),
                      Switch(
                        value: data['status'] == 'Available',
                        onChanged: (value) {
                          _toggleAvailability(docId, value);
                        },
                      ),
                      const SizedBox(
                        width: 64,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditDoctor(
                          docId: docId,
                          currentName: data['name'],
                          currentDesignation: data['designation'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteDoctor(docId),
                      ),
                    ],
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
