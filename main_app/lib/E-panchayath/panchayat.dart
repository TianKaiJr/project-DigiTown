import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'complaint_page.dart';
import 'contact_page.dart';
import 'updates_page.dart';





class PanchayatPage extends StatefulWidget {
  const PanchayatPage({super.key});

  @override
  State<PanchayatPage> createState() => _PanchayatPageState();
}

class _PanchayatPageState extends State<PanchayatPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const NewsEventsScreen(),
    ContactsPage(),
    const ComplaintListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(title: const Text("Panchayat Page")),
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.deepPurple,
        color: Colors.deepPurple.shade200,
        items: const [
          Icon(Icons.update, color: Colors.black),
          Icon(Icons.contacts, color: Colors.black),
          Icon(Icons.edit_document, color: Colors.black),
        ],
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}



