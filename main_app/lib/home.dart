import 'package:flutter/material.dart';
import 'hospital.dart';  // Import the Hospital page
import 'panchayat.dart';  // Import the Panchayat page
import 'palliative_care.dart';  // Import the Palliative Care page

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hospital button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HospitalPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 70), // Increased height
                padding: EdgeInsets.symmetric(vertical: 20), // Increased padding
              ),
              child: Text(
                "Hospital",
                style: TextStyle(fontSize: 22, color: Colors.white), // Increased font size
              ),
            ),
            SizedBox(height: 20),

            // Panchayat button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PanchayatPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 70), // Increased height
                padding: EdgeInsets.symmetric(vertical: 20), // Increased padding
              ),
              child: Text(
                "Panchayat",
                style: TextStyle(fontSize: 22, color: Colors.white), // Increased font size
              ),
            ),
            SizedBox(height: 20),

            // Palliative Care button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PalliativeCarePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 70), // Increased height
                padding: EdgeInsets.symmetric(vertical: 20), // Increased padding
              ),
              child: Text(
                "Palliative Care",
                style: TextStyle(fontSize: 22, color: Colors.white), // Increased font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
