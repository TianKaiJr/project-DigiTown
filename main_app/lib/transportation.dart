import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TransportationPage extends StatelessWidget {
  const TransportationPage({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportation'),
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
                      padding: const EdgeInsets.symmetric(vertical: 40), // Makes the button larger
                      backgroundColor: Colors.blue, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded edges
                      ),
                    ),
                    child: const Text(
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
                        MaterialPageRoute(builder: (context) => const BusPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 40), // Makes the button larger
                      backgroundColor: Colors.blue, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded edges
                      ),
                    ),
                    child: const Text(
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

  TaxiPage({super.key});

  void _showPopupMenu(BuildContext context, String phoneNumber) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        const PopupMenuItem(value: 'message', child: Text('Message')),
        const PopupMenuItem(value: 'call', child: Text('Call')),
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
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxi Service'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: taxiDrivers.length,
        itemBuilder: (context, index) {
          final driver = taxiDrivers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              title: Text('Name: ${driver.name}'),
              subtitle: Text('Phone: ${driver.phone}'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
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


class BusPage extends StatefulWidget {
  const BusPage({super.key});

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  final List<String> places = [
    'City Center',
    'Green Valley',
    'Ocean View',
    'Sunny Hills',
    'Downtown',
    'Tech Park',
    'Uptown',
    'Harbor Station',
  ];

  final List<BusRoute> busRoutes = [
    BusRoute('City Center', 'Green Valley', 'Bus A'),
    BusRoute('Ocean View', 'Sunny Hills', 'Bus B'),
    BusRoute('Downtown', 'Tech Park', 'Bus C'),
    BusRoute('Harbor Station', 'City Center', 'Bus D'),
  ];

  List<String> fromSuggestions = [];
  List<String> toSuggestions = [];
  List<BusRoute> filteredRoutes = [];

  void searchRoutes() {
  setState(() {
    final fromInput = fromController.text.toLowerCase();
    final toInput = toController.text.toLowerCase();

    filteredRoutes = busRoutes.where((route) {
      final routeFrom = route.from.toLowerCase();
      final routeTo = route.to.toLowerCase();

      // Check if both "from" and "to" inputs match the routes (partial matches allowed)
      return routeFrom.contains(fromInput) && routeTo.contains(toInput);
    }).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Service'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // "From" TextField with suggestions
            TextField(
              controller: fromController,
              decoration: const InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  fromSuggestions = places
                      .where((place) => place.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            if (fromSuggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                height: 100,
                child: ListView.builder(
                  itemCount: fromSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(fromSuggestions[index]),
                      onTap: () {
                        setState(() {
                          fromController.text = fromSuggestions[index];
                          fromSuggestions.clear();
                        });
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // "To" TextField with suggestions
            TextField(
              controller: toController,
              decoration: const InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  toSuggestions = places
                      .where((place) => place.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            if (toSuggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                height: 100,
                child: ListView.builder(
                  itemCount: toSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(toSuggestions[index]),
                      onTap: () {
                        setState(() {
                          toController.text = toSuggestions[index];
                          toSuggestions.clear();
                        });
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Search Button
            ElevatedButton(
              onPressed: searchRoutes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              ),
              child: const Text(
                'Search Buses',
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 16),

            // Filtered Bus Routes
            Expanded(
              child: filteredRoutes.isEmpty
                  ? const Center(child: Text('No buses found'))
                  : ListView.builder(
                      itemCount: filteredRoutes.length,
                      itemBuilder: (context, index) {
                        final route = filteredRoutes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            title: Text('Bus: ${route.busName}'),
                            subtitle: Text('From: ${route.from} → To: ${route.to}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusRoute {
  final String from;
  final String to;
  final String busName;

  BusRoute(this.from, this.to, this.busName);
}
