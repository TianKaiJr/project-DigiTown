import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  _AppointmentListPageState createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateMissingStatuses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// One-time update: Assign 'Pending' status to documents that don't have it
  Future<void> _updateMissingStatuses() async {
    final collectionRef =
        FirebaseFirestore.instance.collection('Hospital_Appointments');
    final querySnapshot = await collectionRef.get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>? ?? {};
      if (!data.containsKey('status')) {
        await collectionRef.doc(doc.id).update({'status': 'Pending'});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Hospital Appointments"),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Confirmed"),
              Tab(text: "Cancelled"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList("Pending"),
                _buildAppointmentList("Confirmed"),
                _buildAppointmentList("Cancelled"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
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

        var appointments = snapshot.data!.docs
            .map((doc) {
              var data = doc.data() as Map<String, dynamic>? ?? {};

              data['status'] ??= 'Pending'; // Ensure status is set

              return {'id': doc.id, 'data': data};
            })
            .where((doc) =>
                (doc['data'] as Map<String, dynamic>?)?['status'] ==
                statusFilter)
            .toList();

        if (appointments.isEmpty) {
          return const Center(child: Text('No appointments found.'));
        }

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            var appointment = appointments[index];
            var data = appointment['data'] as Map<String, dynamic>? ?? {};

            String currentStatus = data['status'] ?? 'Pending';
            List<String> statusOptions = ['Pending', 'Confirmed', 'Cancelled'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(data['patientName'] ?? 'No Name'),
                subtitle: Text(
                    'Date: ${data['date'] ?? 'N/A'} | Time: ${data['time'] ?? 'N/A'}\n'
                    'Department: ${data['department'] ?? 'N/A'}\n'
                    'Hospital: ${data['hospitalName'] ?? 'N/A'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deleteAppointment(appointment['id'] as String),
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
                          _updateAppointmentStatus(
                              appointment['id'] as String, newStatus);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () => _showEditDialog(context, data),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateAppointmentStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('Hospital_Appointments')
        .doc(docId)
        .update({'status': newStatus});
  }

  Future<void> _deleteAppointment(String docId) async {
    await FirebaseFirestore.instance
        .collection('Hospital_Appointments')
        .doc(docId)
        .delete();
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> data) {
    TextEditingController patientNameController =
        TextEditingController(text: data['patientName'] ?? '');
    TextEditingController phoneController =
        TextEditingController(text: data['phoneNumber'] ?? '');
    TextEditingController reasonController =
        TextEditingController(text: data['reason'] ?? '');
    TextEditingController departmentController =
        TextEditingController(text: data['department'] ?? '');
    TextEditingController dateController =
        TextEditingController(text: data['date'] ?? '');
    TextEditingController timeController =
        TextEditingController(text: data['time'] ?? '');
    TextEditingController addressController =
        TextEditingController(text: data['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Appointment Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: patientNameController,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Patient Name')),
                const SizedBox(height: 10),
                TextField(
                    controller: phoneController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 10),
                TextField(
                    controller: reasonController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Reason')),
                const SizedBox(height: 10),
                TextField(
                    controller: departmentController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Department')),
                const SizedBox(height: 10),
                TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Date')),
                const SizedBox(height: 10),
                TextField(
                    controller: timeController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Time')),
                const SizedBox(height: 10),
                TextField(
                    controller: addressController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Address')),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
          ],
        );
      },
    );
  }
}
