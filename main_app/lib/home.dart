import 'package:flutter/material.dart';
import 'hospital.dart'; // Import the Hospital page
import 'panchayat.dart'; // Import the Panchayat page
import 'palliative_care.dart'; // Import the Palliative Care page
import 'transportation.dart'; // Import the Transportation page
import 'blood.dart'; // Import the Blood page

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Background Decoration
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
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Hospital Box
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HospitalPage()),
                        );
                      },
                      child: _buildOptionBox(
                        color: Colors.purple,
                        icon: Icons.local_hospital,
                        label: "Hospital",
                      ),
                    ),

                    // Panchayat Box
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PanchayatPage()),
                        );
                      },
                      child: _buildOptionBox(
                        color: Colors.blue,
                        icon: Icons.account_balance,
                        label: "Panchayat",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Palliative Care Box
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PalliativeCarePage()),
                        );
                      },
                      child: _buildOptionBox(
                        color: Colors.green,
                        icon: Icons.healing,
                        label: "Palliative Care",
                      ),
                    ),

                    // Transportation Box
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TransportationPage()),
                        );
                      },
                      child: _buildOptionBox(
                        color: Colors.orange,
                        icon: Icons.directions_bus,
                        label: "Transportation",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Blood Box
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BloodPage()),
                    );
                  },
                  child: _buildOptionBox(
                    color: Colors.red,
                    icon: Icons.bloodtype,
                    label: "Blood",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBox({required Color color, required IconData icon, required String label}) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(2, 2),
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
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
