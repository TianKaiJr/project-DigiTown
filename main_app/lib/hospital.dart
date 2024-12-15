import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs (e.g., calls, maps)

class HospitalPage extends StatelessWidget {
  final List<Map<String, String>> hospitals = [
    {
      'name': 'City Hospital',
      'address': '123 Main Street, Cityville',
      'phone': '1234567890',
    },
    {
      'name': 'Town Health Center',
      'address': '456 Elm Street, Townsville',
      'phone': '0987654321',
    },
  ];

  final List<String> healthTips = [
    'Drink plenty of water to stay hydrated.',
    'Get at least 7-8 hours of sleep daily.',
    'Wash your hands regularly to avoid infections.',
    'Exercise for at least 30 minutes a day.'
  ];

  void _launchCaller(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchMaps(String address) async {
    final Uri url = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {'q': address},
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openAppointmentForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Preferred Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Logic to handle form submission can be added here
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Services'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Welcome to the Hospital Service Page',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Nearby Hospitals',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              ...hospitals.map((hospital) => Card(
                    child: ListTile(
                      title: Text(hospital['name']!),
                      subtitle: Text(hospital['address']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.map, color: Colors.blue),
                            onPressed: () => _launchMaps(hospital['address']!),
                          ),
                          IconButton(
                            icon: Icon(Icons.phone, color: Colors.green),
                            onPressed: () => _launchCaller(hospital['phone']!),
                          ),
                        ],
                      ),
                    ),
                  )),
              SizedBox(height: 20.0),
              Text(
                'Book an Appointment',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
             ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, 'y'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
                ),
                ),
              child: Text('Book Now'), // This should be placed outside the style property
            ),

              SizedBox(height: 20.0),
              Text(
                'Location and Navigation',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Card(
                child: ListTile(
                  title: Text('Find Nearby Hospitals'),
                  trailing: Icon(Icons.map,color: Colors.blue,),
                  onTap: () {
                    _launchMaps('hospitals near me');
                  },
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Health Tips',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              ...healthTips.map((tip) => ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(tip),
                  )),
            ],
          );
        },
      ),
    );
  }
}
