import 'package:flutter/material.dart';
import 'package:main2/_Panchayat/my_button.dart';
import 'bus_service_page.dart';
import 'taxi_service_page.dart';

class TransportationPage extends StatelessWidget {
  const TransportationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transportation Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // centerTitle: true,
        // backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            MyButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TaxiServicePage()),
                  );
                },
                text: 'Taxi Service'),
            const SizedBox(height: 20),
            MyButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BusServicePage()),
                  );
                },
                text: 'Bus Route Service'),
          ],
        ),
      ),
    );
  }
}
