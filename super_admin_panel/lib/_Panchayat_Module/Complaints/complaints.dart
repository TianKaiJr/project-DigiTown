import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/___Core/Theme/app_pallete.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class ComplaintListPage extends StatefulWidget {
  const ComplaintListPage({super.key});

  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  bool enable_WriteMode = false;

  @override
  void initState() {
    super.initState();
    _checkAndUpdateComplaints();
  }

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
                  subtitle: Text('Type: ${complaint['issueType']}'),
                  onTap: () => _showEditDialog(context, complaint),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteComplaint(complaint.id),
                      ),
                      const SizedBox(width: 10),
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
        visible: enable_WriteMode,
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

  Future<void> _updateComplaintStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection('Complaint_MGR')
        .doc(docId)
        .update({'status': status});
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    enable_WriteMode ? 'Edit Complaint' : 'View Complaint',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Divider(),
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
                        const SizedBox(height: 10),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkAndUpdateComplaints() async {
    final collection = FirebaseFirestore.instance.collection('Complaint_MGR');
    final snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      if (!doc.exists || doc.data().containsKey('c_id')) continue;

      String email = doc['email'] ?? '';
      String username = doc['username'] ?? '';
      String cId = '$email$username';

      await collection.doc(doc.id).update({'c_id': cId});
    }
  }

  void _showCreateComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Complaint'),
          content: const Text('Complaint creation functionality goes here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
