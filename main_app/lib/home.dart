import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_app/components/drawer.dart';
import 'package:main_app/profile_page.dart';
import 'hospital.dart';
import 'panchayat.dart';
import 'palliative_care.dart';
import 'transportation.dart';
import 'blood.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void goToProfilePage(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    bool? shouldExit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Exit"),
        content: const Text("Do you really want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitConfirmationDialog(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _showExitConfirmationDialog(context)) {
              }
            },
          ),
        ),
        endDrawer: MyDrawer(
          onProfileTap: () => goToProfilePage(context),
          onSignOut: () {},
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.shade100,
                    Colors.teal.shade300,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _buildNeumorphicOptionBox(
                      context,
                      color: Colors.purple,
                      icon: Icons.local_hospital,
                      label: "Hospital",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HospitalPage()),
                        );
                      },
                    ),
                    _buildNeumorphicOptionBox(
                      context,
                      color: Colors.blue,
                      icon: Icons.account_balance,
                      label: "Panchayat",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PanchayatPage()),
                        );
                      },
                    ),
                    _buildNeumorphicOptionBox(
                      context,
                      color: Colors.green,
                      icon: Icons.healing,
                      label: "Palliative Care",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PalliativeCarePage()),
                        );
                      },
                    ),
                    _buildNeumorphicOptionBox(
                      context,
                      color: Colors.orange,
                      icon: Icons.directions_bus,
                      label: "Transportation",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TransportationPage()),
                        );
                      },
                    ),
                    _buildNeumorphicOptionBox(
                      context,
                      color: Colors.red,
                      icon: Icons.bloodtype,
                      label: "Blood",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BloodPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeumorphicOptionBox(
      BuildContext context, {
      required Color color,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(5, 5),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(-5, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
