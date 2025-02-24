import 'package:flutter/material.dart';
import 'bus_service_page.dart';
import 'taxi_service_page.dart';

class TransportationPage extends StatelessWidget {
  const TransportationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportation'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TaxiServicePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Taxi Service',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusServicePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Bus Service',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
