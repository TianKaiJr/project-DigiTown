import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TransportationPage extends StatelessWidget {
  const TransportationPage({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transportation'),
        centerTitle: true,
        backgroundColor: Colors.blue, // Primary color
      ),
      body: Container(
        color: Colors.grey[200], // Secondary color for background
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaxiPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 40), // Makes the button larger
                      backgroundColor: Colors.blue, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded edges
                      ),
                    ),
                    child: Text(
                      'Taxi Service',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BusPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 40), // Makes the button larger
                      backgroundColor: Colors.blue, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded edges
                      ),
                    ),
                    child: Text(
                      'Bus Service',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaxiPage extends StatelessWidget {
  final List<Driver> taxiDrivers = [
    Driver('John Doe', '+1234567890'),
    Driver('Jane Smith', '+19876543210'),
    Driver('Mike Johnson', '+15551234567'),
    Driver('Emily Davis', '+14447891234'),
  ];

  void _showPopupMenu(BuildContext context, String phoneNumber) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(value: 'message', child: Text('Message')),
        PopupMenuItem(value: 'call', child: Text('Call')),
      ],
    ).then((value) {
      if (value == 'message') {
        _openWhatsApp(context, phoneNumber);
      } else if (value == 'call') {
        _makeCall(context, phoneNumber);
      }
    });
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    final String url = 'https://wa.me/$phoneNumber';
    if (!await _validateAndLaunch(context, url)) {
      _showErrorDialog(context, 'Could not launch WhatsApp.');
    }
  }

  Future<void> _makeCall(BuildContext context, String phoneNumber) async {
    final String url = 'tel:$phoneNumber';
    if (!await _validateAndLaunch(context, url)) {
      _showErrorDialog(context, 'Could not make the call.');
    }
  }

  Future<bool> _validateAndLaunch(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
      return true;
    }
    return false;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taxi Service'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: taxiDrivers.length,
        itemBuilder: (context, index) {
          final driver = taxiDrivers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              title: Text('Name: ${driver.name}'),
              subtitle: Text('Phone: ${driver.phone}'),
              trailing: IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () => _showPopupMenu(context, driver.phone),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Driver {
  final String name;
  final String phone;

  Driver(this.name, this.phone);
}


class BusPage extends StatelessWidget {
  const BusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Service'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Bus Service Page!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
