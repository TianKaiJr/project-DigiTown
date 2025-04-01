import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComplaintListPage extends StatefulWidget {
  const ComplaintListPage({super.key});

  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.deepPurple,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 10.0),
            child: Center(
              child: Text(
                "Complaints",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Complaint_MGR')
                  .where('issueType', isEqualTo: 'Public')
                  .snapshots(),
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

                    String subject = complaint['subject'] ?? 'No Subject';
                    String details = complaint['details'] ?? 'No Details';
                    String status = complaint['status'] ?? 'Unknown';

                    return Card(
                      // color: Colors.deepPurple.shade200,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(subject,
                            style: TextStyle(color: Colors.black)),
                        subtitle: Text('Details: $details\nStatus: $status',
                            style: TextStyle(color: Colors.black)),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.black),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteComplaint(complaint.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateComplaintDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteComplaint(String docId) async {
    await FirebaseFirestore.instance
        .collection('Complaint_MGR')
        .doc(docId)
        .delete();
  }

  void _showCreateComplaintDialog(BuildContext context) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController contactController = TextEditingController();
    final TextEditingController statusController =
        TextEditingController(text: "Under Review");

    String selectedIssueType = "Public";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.9, // Set width dynamically
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // color: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              // Prevents overflow
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'New Complaint',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter the subject' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: detailsController,
                      decoration: const InputDecoration(labelText: 'Details'),
                      maxLines: 3,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter the details' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your username' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email ID'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your email ID' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: contactController,
                      decoration:
                          const InputDecoration(labelText: 'Contact Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your contact number'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedIssueType,
                      decoration:
                          const InputDecoration(labelText: 'Type of Issue'),
                      items: ['Public', 'Private'].map((String category) {
                        return DropdownMenuItem(
                            value: category, child: Text(category));
                      }).toList(),
                      onChanged: (newValue) {
                        selectedIssueType = newValue!;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await FirebaseFirestore.instance
                                  .collection('Complaint_MGR')
                                  .add({
                                'subject': subjectController.text,
                                'details': detailsController.text,
                                'username': usernameController.text,
                                'email': emailController.text,
                                'contact': contactController.text,
                                'issueType': selectedIssueType,
                                'status': statusController.text,
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
