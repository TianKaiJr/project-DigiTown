import 'package:flutter/material.dart';
import 'package:main2/_PalliativeCare/palliative_care.dart';
import 'package:main2/_PalliativeCare/view_bookings.dart';

class PalliativeTabs extends StatefulWidget {
  const PalliativeTabs({super.key});

  @override
  State<PalliativeTabs> createState() => _PalliativeTabsState();
}

class _PalliativeTabsState extends State<PalliativeTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text("Palliative Care"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Book Service"),
            Tab(text: "View Bookings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PalliativeCarePage(), // Book Service Page
          ViewBookingsPage() // Placeholder for View Bookings
        ],
      ),
    );
  }
}
