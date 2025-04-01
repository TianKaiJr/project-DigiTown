import 'package:flutter/material.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:main2/_BloodBank/blood.dart';
import 'package:main2/_Hospital/hospital.dart';
import 'package:main2/_PalliativeCare/palliative_tabs.dart';
import 'package:main2/_Panchayat/panchayat.dart';
import 'package:main2/_Transport/transportation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    PanchayatPage(),
    BloodPage(),
    TransportationPage(),
    HospitalPage(),
    PalliativeTabs(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CrystalNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.6)
            : const Color.fromARGB(255, 204, 202, 202).withOpacity(0.6),
        borderRadius: 30,
        items: [
          CrystalNavigationBarItem(
            icon: Icons.account_balance,
            selectedColor: Colors.green,
          ),
          CrystalNavigationBarItem(
            icon: Icons.bloodtype,
            selectedColor: Colors.red,
          ),
          CrystalNavigationBarItem(
            icon: Icons.local_taxi,
            selectedColor: Colors.orange,
          ),
          CrystalNavigationBarItem(
            icon: Icons.local_hospital,
            selectedColor: Colors.blue,
          ),
          CrystalNavigationBarItem(
            icon: Icons.volunteer_activism,
            selectedColor: Colors.pink,
          ),
        ],
      ),
    );
  }
}
