import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class HospitalDepartmentsScreen extends StatefulWidget {
  const HospitalDepartmentsScreen({super.key});

  @override
  _HospitalDepartmentsScreenState createState() =>
      _HospitalDepartmentsScreenState();
}

class _HospitalDepartmentsScreenState extends State<HospitalDepartmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _deptNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Hospital Departments',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _deptNameController,
              decoration: const InputDecoration(
                labelText: 'Department Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addDepartment,
              child: const Text('Add Department'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore.collection('Hospital_Departments').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var departments = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: departments.length,
                    itemBuilder: (context, index) {
                      var dept = departments[index];
                      return ListTile(
                        title: Text(dept['name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteDepartment(dept.id),
                        ),
                        onTap: () {
                          // Show update dialog when a department is clicked
                          _showUpdateDialog(dept.id, dept['name']);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addDepartment() async {
    if (_deptNameController.text.isEmpty) return;
    await _firestore.collection('Hospital_Departments').add({
      'name': _deptNameController.text,
    });
    _deptNameController.clear();
  }

  void _deleteDepartment(String deptId) async {
    await _firestore.collection('Hospital_Departments').doc(deptId).delete();
  }

  void _showUpdateDialog(String deptId, String currentName) {
    final TextEditingController _updateController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Department'),
          content: TextField(
            controller: _updateController,
            decoration: const InputDecoration(
              labelText: 'Department Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_updateController.text.isNotEmpty) {
                  await _firestore
                      .collection('Hospital_Departments')
                      .doc(deptId)
                      .update({
                    'name': _updateController.text,
                  });
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _deptNameController.dispose();
    super.dispose();
  }
}
