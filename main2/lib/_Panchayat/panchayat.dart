import 'package:flutter/material.dart';
import 'complaint_page.dart';
import 'contact_page.dart';
import 'updates_page.dart';

class PanchayatPage extends StatefulWidget {
  const PanchayatPage({super.key});

  @override
  State<PanchayatPage> createState() => _PanchayatPageState();
}

class _PanchayatPageState extends State<PanchayatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panchayat Services"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Updates"),
            Tab(text: "Contacts"),
            Tab(text: "Complaints"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const NewsEventsScreen(),
          ContactsPage(),
          const ComplaintListPage(),
        ],
      ),
    );
  }
}
