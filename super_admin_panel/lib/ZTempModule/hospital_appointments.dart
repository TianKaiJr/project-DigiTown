import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  _AppointmentListPageState createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  bool enable_WriteMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Hospital Appointments"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Hospital_Appointments')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          var appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              String currentStatus = appointment['status'] ?? 'Pending';

              List<String> statusOptions = [
                'Pending',
                'Confirmed',
                'Cancelled'
              ];

              // Ensure status is always valid
              if (!statusOptions.contains(currentStatus)) {
                currentStatus = 'Pending';
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(appointment['patient_name'] ?? 'No Name'),
                  subtitle: Text(
                      'Date & Duration: ${appointment['date_n_duration']}'),
                  onTap: () => _showEditDialog(context, appointment),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAppointment(appointment.id),
                      ),
                      DropdownButton<String>(
                        value: currentStatus,
                        items: statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newStatus) {
                          if (newStatus != null) {
                            _updateAppointmentStatus(appointment.id, newStatus);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: enable_WriteMode,
        child: FloatingActionButton(
          onPressed: () => _showCreateAppointmentDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// Method to update appointment status
  Future<void> _updateAppointmentStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('Hospital_Appointments')
        .doc(docId)
        .update({
      'status': newStatus,
    });
  }

  /// Method to delete an appointment
  Future<void> _deleteAppointment(String docId) async {
    await FirebaseFirestore.instance
        .collection('Hospital_Appointments')
        .doc(docId)
        .delete();
  }

  /// Method to show edit/view dialog
  void _showEditDialog(BuildContext context, DocumentSnapshot appointment) {
    TextEditingController nameController =
        TextEditingController(text: appointment['patient_name']);
    TextEditingController emailController =
        TextEditingController(text: appointment['email']);
    TextEditingController phoneController =
        TextEditingController(text: appointment['phone']);
    TextEditingController aadhaarController =
        TextEditingController(text: appointment['aadhaar_proof']);
    TextEditingController genderController =
        TextEditingController(text: appointment['gender']);
    TextEditingController historyController =
        TextEditingController(text: appointment['medical_history']);
    TextEditingController dateController =
        TextEditingController(text: appointment['date_n_duration']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(enable_WriteMode ? 'Edit Appointment' : 'View Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    readOnly: !enable_WriteMode,
                    decoration:
                        const InputDecoration(labelText: 'Patient Name')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: emailController,
                    readOnly: !enable_WriteMode,
                    decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: phoneController,
                    readOnly: !enable_WriteMode,
                    decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: aadhaarController,
                    readOnly: !enable_WriteMode,
                    decoration:
                        const InputDecoration(labelText: 'Aadhaar Proof')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: genderController,
                    readOnly: !enable_WriteMode,
                    decoration: const InputDecoration(labelText: 'Gender')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: historyController,
                    readOnly: !enable_WriteMode,
                    decoration:
                        const InputDecoration(labelText: 'Medical History')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: dateController,
                    readOnly: !enable_WriteMode,
                    decoration:
                        const InputDecoration(labelText: 'Date & Duration')),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          actions: enable_WriteMode
              ? [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('Hospital_Appointments')
                          .doc(appointment.id)
                          .update({
                        'patient_name': nameController.text,
                        'email': emailController.text,
                        'phone': phoneController.text,
                        'aadhaar_proof': aadhaarController.text,
                        'gender': genderController.text,
                        'medical_history': historyController.text,
                        'date_n_duration': dateController.text,
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Update'),
                  ),
                ]
              : null,
        );
      },
    );
  }

  /// Method to create a new appointment
  void _showCreateAppointmentDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController aadhaarController = TextEditingController();
    TextEditingController genderController = TextEditingController();
    TextEditingController historyController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Patient Name')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: aadhaarController,
                    decoration:
                        const InputDecoration(labelText: 'Aadhaar Proof')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: genderController,
                    decoration: const InputDecoration(labelText: 'Gender')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: historyController,
                    decoration:
                        const InputDecoration(labelText: 'Medical History')),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: dateController,
                    decoration:
                        const InputDecoration(labelText: 'Date & Duration')),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Hospital_Appointments')
                    .add({
                  'patient_name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'aadhaar_proof': aadhaarController.text,
                  'gender': genderController.text,
                  'medical_history': historyController.text,
                  'date_n_duration': dateController.text,
                  'status': 'Pending',
                });
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
