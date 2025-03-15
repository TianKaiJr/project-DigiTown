import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';

class PalliativeAppointmentsScreen extends StatefulWidget {
  const PalliativeAppointmentsScreen({super.key});

  @override
  _PalliativeAppointmentsScreenState createState() =>
      _PalliativeAppointmentsScreenState();
}

class _PalliativeAppointmentsScreenState
    extends State<PalliativeAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('bookings').doc(docId).update({
      'status': newStatus,
    });
  }

  Widget buildAppointmentList(String status) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $status appointments"));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text("${data['name']} - ${data['service']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "📍 ${data['address']}\n📅 ${data['date']}, 🕒 ${data['time']}"),
                trailing: status == "Pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            onPressed: () => updateStatus(doc.id, "Accepted"),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => updateStatus(doc.id, "Rejected"),
                          ),
                        ],
                      )
                    : Icon(
                        status == "Accepted"
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            status == "Accepted" ? Colors.green : Colors.red),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Palliative Care Appointments"),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: const Color.fromARGB(255, 255, 255, 255),
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildAppointmentList("Pending"),
                buildAppointmentList("Accepted"),
                buildAppointmentList("Rejected"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
