import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:super_admin_panel/___Core/Theme/app_pallete.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class ComplaintListPage extends StatefulWidget {
  const ComplaintListPage({super.key});

  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  bool enable_WriteMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Complaints"),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('Complaint_MGR').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }

          var complaints = snapshot.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              var complaint = complaints[index];
              String currentStatus = complaint['status'] ?? 'Under Review';

              return Card(
                color: AppPallete.secondaryColor,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(complaint['subject'] ?? 'No Subject'),
                  subtitle: Text('Type: ${complaint['type']}'),
                  onTap: () => _showEditDialog(context, complaint),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteComplaint(complaint.id),
                      ),
                      const SizedBox(width: 10), // Add spacing between buttons
                      DropdownButton<String>(
                        value: currentStatus,
                        items: ['Under Review', 'Accepted', 'Rejected']
                            .map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newStatus) {
                          if (newStatus != null) {
                            _updateComplaintStatus(complaint.id, newStatus);
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
        visible:
            enable_WriteMode, // Set this to true to make the button visible
        child: FloatingActionButton(
          onPressed: () => _showCreateComplaintDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _deleteComplaint(String docId) async {
    await FirebaseFirestore.instance
        .collection('Complaint_MGR')
        .doc(docId)
        .delete();
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot complaint) {
    TextEditingController subjectController =
        TextEditingController(text: complaint['subject']);
    TextEditingController detailController =
        TextEditingController(text: complaint['details']);
    TextEditingController usernameController =
        TextEditingController(text: complaint['username']);
    TextEditingController emailController =
        TextEditingController(text: complaint['email']);
    TextEditingController contactController =
        TextEditingController(text: complaint['contact']);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height *
                0.75, // Set height to 75% of screen height
            child: Column(
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    enable_WriteMode ? 'Edit Complaint' : 'View Complaint',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge, // Use a theme for consistency
                  ),
                ),
                const Divider(), // Optional divider between title and content
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          readOnly: !enable_WriteMode,
                          controller: usernameController,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          readOnly: !enable_WriteMode,
                          controller: emailController,
                          decoration:
                              const InputDecoration(labelText: 'Email ID'),
                        ),
                        TextField(
                          readOnly: !enable_WriteMode,
                          controller: contactController,
                          decoration: const InputDecoration(
                              labelText: 'Contact Number'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          readOnly: !enable_WriteMode,
                          controller: subjectController,
                          decoration:
                              const InputDecoration(labelText: 'Subject'),
                        ),
                        const SizedBox(
                            height: 10), // Use SizedBox instead of Gap
                        TextField(
                          readOnly: !enable_WriteMode,
                          controller: detailController,
                          decoration:
                              const InputDecoration(labelText: 'Details'),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                // Actions (Only if enabled)
                if (enable_WriteMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('Complaint_MGR')
                                .doc(complaint.id)
                                .update({
                              'subject': subjectController.text,
                              'details': detailController.text,
                              'username': usernameController.text,
                              'email': emailController.text,
                              'contact': contactController.text,
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateComplaintDialog(BuildContext context) async {
    TextEditingController subjectController = TextEditingController();
    TextEditingController detailController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController contactController = TextEditingController();
    String complaintType = 'Public';
    int complaintId = await _getNextComplaintId();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Complaint'),
          content: SingleChildScrollView(
            // Use SingleChildScrollView to avoid overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const Gap(5),
                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(labelText: 'Details'),
                  maxLines: 4,
                ),
                const Gap(5),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const Gap(5),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email ID'),
                ),
                const Gap(5),
                TextField(
                  controller: contactController,
                  decoration:
                      const InputDecoration(labelText: 'Contact Number'),
                ),
                const Gap(5),
                DropdownButtonFormField(
                  value: complaintType,
                  items: ['Public', 'Private'].map((String type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      complaintType = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Type of Issue'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Complaint_MGR')
                    .add({
                  'complaint_id': complaintId,
                  'subject': subjectController.text,
                  'details': detailController.text,
                  'type': complaintType,
                  'username': usernameController.text,
                  'email': emailController.text,
                  'contact': contactController.text,
                  'status': 'Under Review', // Default status
                });
                await _updateComplaintId(complaintId);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<int> _getNextComplaintId() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('ID_Counters')
        .doc('permanent_counters_skeleton')
        .get();
    int currentId = snapshot['complaint_id'];
    return currentId + 1;
  }

  Future<void> _updateComplaintId(int newId) async {
    await FirebaseFirestore.instance
        .collection('ID_Counters')
        .doc('permanent_counters_skeleton')
        .update({'complaint_id': newId});
  }

  Future<void> _updateComplaintStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection('Complaint_MGR')
        .doc(docId)
        .update({'status': status});
  }
}
