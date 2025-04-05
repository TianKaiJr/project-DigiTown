import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class AddHospitalsScreen extends StatefulWidget {
  const AddHospitalsScreen({super.key});

  @override
  _AddHospitalsScreenState createState() => _AddHospitalsScreenState();
}

class _AddHospitalsScreenState extends State<AddHospitalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<String> _selectedDepartments = [];
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final snapshot =
          await _firestore.collection('Hospital_Departments').get();
      setState(() {
        _departments = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc['name'],
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching departments: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Hospitals',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Hospitals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var hospitals = snapshot.data!.docs;
          return ListView.builder(
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              var hospital = hospitals[index];
              return ListTile(
                title: Text(hospital['Name']),
                subtitle: Text(hospital['Address']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteHospital(hospital.id),
                ),
                onTap: () => _showUpdateDialog(
                  hospital.id,
                  hospital['Name'],
                  hospital['Address'],
                  List<String>.from(hospital['Departments']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    _nameController.clear();
    _addressController.clear();
    _selectedDepartments.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Hospital'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Select Departments:'),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : MultiSelectContainer(
                        items: _departments.map((dept) {
                          return MultiSelectCard(
                            value: dept['id'],
                            label: dept['name'],
                          );
                        }).toList(),
                        onChange: (allSelectedItems, selectedItem) {
                          _selectedDepartments =
                              List<String>.from(allSelectedItems);
                        },
                      ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addHospital,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addHospital() async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('Hospitals').add({
        'Name': _nameController.text,
        'Address': _nameController.text,
        'Departments': _selectedDepartments,
        'phone': _phoneController.text
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding hospital: $e')),
      );
    }
  }

  void _showUpdateDialog(String hospitalId, String currentName,
      String currentAddress, List<String> currentDepartments) {
    final TextEditingController updateNameController =
        TextEditingController(text: currentName);
    final TextEditingController updateAddressController =
        TextEditingController(text: currentAddress);
    List<String> updatedDepartments = List.from(currentDepartments);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Hospital'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: updateNameController,
                      decoration: const InputDecoration(
                        labelText: 'Hospital Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: updateAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Departments:'),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : MultiSelectContainer(
                            items: _departments.map((dept) {
                              return MultiSelectCard(
                                value: dept['id'],
                                label: dept['name'],
                              );
                            }).toList(),
                            onChange: (allSelectedItems, selectedItem) {
                              setState(() {
                                updatedDepartments =
                                    List<String>.from(allSelectedItems);
                              });
                            },
                          ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (updateNameController.text.isNotEmpty &&
                        updateAddressController.text.isNotEmpty) {
                      try {
                        await _firestore
                            .collection('Hospitals')
                            .doc(hospitalId)
                            .update({
                          'Name': updateNameController.text,
                          'Address': updateAddressController.text,
                          'Departments': updatedDepartments,
                        });
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error updating hospital: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteHospital(String hospitalId) async {
    try {
      await _firestore.collection('Hospitals').doc(hospitalId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting hospital: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
