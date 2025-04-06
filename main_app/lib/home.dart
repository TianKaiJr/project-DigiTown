import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:main_app/profile_page.dart';
import 'hospital.dart';
import 'E-panchayath/panchayat.dart';
import 'palliative_care.dart';
import 'transportation.dart';
import 'blood.dart';
import 'login.dart';

// -------------------------------------------------------------------
// ContactUsPage: Only "Email Us" option + location & email details
// -------------------------------------------------------------------
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  // Method to launch the email client
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'digitown.app@gmail.com',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color(0xFFDFFAE5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Don't hesitate to contact us whether you have a suggestion on our improvement, a complaint to discuss, or an issue to solve.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'digitown.app@gmail.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Kalady,Kerala\nIndia,683574',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _launchEmail,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email,
                      size: 36,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Email Us",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Our team is online Mon-Fri",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
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
}

// -------------------------------------------------------------------
// MyDrawer: Drawer widget with Home, Person, Contact Us, Logout
// -------------------------------------------------------------------
class MyDrawer extends StatelessWidget {
  const MyDrawer({
    Key? key,
    required this.onProfileTap,
    required this.onHomeTap,
    required this.onLogoutTap,
  }) : super(key: key);

  final VoidCallback onProfileTap;
  final VoidCallback onHomeTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF81CDC8),
              Color(0xFFACECEB),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 60),
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.teal,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                onHomeTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('Person'),
              onTap: () {
                Navigator.pop(context);
                onProfileTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.black),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                onLogoutTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// HomePage: Uses the MyDrawer and provides options for navigation
// -------------------------------------------------------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void goToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void goToHomePage(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // Updated logout function: sign out from Firebase and clear persistent flag
  void handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // Clear persistent login flag if you are using shared_preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('isLoggedIn');

              Navigator.pop(context); // Close the dialog

              // Navigate to the LoginPage replacing the current route
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  // Confirm exit dialog when the user attempts to exit the app
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
              await _showExitConfirmationDialog(context);
            },
          ),
        ),
        endDrawer: MyDrawer(
          onProfileTap: () => goToProfilePage(context),
          onHomeTap: () => goToHomePage(context),
          onLogoutTap: () => handleLogout(context),
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
                            builder: (context) => const HospitalPage(),
                          ),
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
                            builder: (context) => const PanchayatPage(),
                          ),
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
                            builder: (context) => const PalliativeCarePage(),
                          ),
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
                            builder: (context) => const TransportationPage(),
                          ),
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
                          MaterialPageRoute(
                            builder: (context) => const BloodMainPage(),
                          ),
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
    required VoidCallback onTap,
  }) {
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
