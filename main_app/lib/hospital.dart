import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs (e.g., calls, maps)

class HospitalPage extends StatefulWidget {
  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
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
    {
      'name': 'Sunrise Medical',
      'address': '789 Oak Street, Sunnytown',
      'phone': '1122334455',
    },
    {
      'name': 'Green Valley Clinic',
      'address': '101 Pine Street, Greenfield',
      'phone': '5566778899',
    },
  ];

  List<Map<String, String>> filteredHospitals = [];
  TextEditingController _searchController = TextEditingController();

  final List<String> healthTips = [
    'Drink plenty of water to stay hydrated.',
    'Get at least 7-8 hours of sleep daily.',
    'Wash your hands regularly to avoid infections.',
    'Exercise for at least 30 minutes a day.'
  ];

  @override
  void initState() {
    super.initState();
    filteredHospitals = hospitals;
    _searchController.addListener(_filterHospitals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterHospitals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredHospitals = hospitals.where((hospital) {
        return hospital['name']!.toLowerCase().contains(query) ||
            hospital['address']!.toLowerCase().contains(query);
      }).toList();
    });
  }

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
        title: const Text('Book Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Services'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Welcome to the Hospital Service Page',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Nearby Hospitals',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Hospitals',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              ...filteredHospitals.map((hospital) => Card(
                    child: ListTile(
                      title: Text(hospital['name']!),
                      subtitle: Text(hospital['address']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIcon(
                            context,
                            icon: Icons.map,
                            label: 'Open Location',
                            onTap: () => _launchMaps(hospital['address']!),
                          ),
                          const SizedBox(width: 8),
                          _buildIcon(
                            context,
                            icon: Icons.phone,
                            label: 'Call Hospital',
                            onTap: () => _launchCaller(hospital['phone']!),
                          ),
                          const SizedBox(width: 8),
                          _buildIcon(
                            context,
                            icon: Icons.medical_services,
                            label: 'Doctor Availability',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DoctorsAvailabilityPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 20.0),
              const Text(
                'Book an Appointment',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, 'y'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Book Now'),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Location and Navigation',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Card(
                child: ListTile(
                  title: const Text('Find Nearby Hospitals'),
                  trailing: const Icon(Icons.map, color: Colors.blue),
                  onTap: () {
                    _launchMaps('hospitals near me');
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Health Tips',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              ...healthTips.map((tip) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(tip),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIcon(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(label)),
        );
      },
      child: Tooltip(
        message: label,
        child: Icon(icon, size: 28, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class DoctorsAvailabilityPage extends StatelessWidget {
  const DoctorsAvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors Availability'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: const [
          ListTile(
            title: Text('Dr. John Doe'),
            subtitle: Text('Available: 9:00 AM - 5:00 PM'),
            leading: Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          ListTile(
            title: Text('Dr. Jane Smith'),
            subtitle: Text('Available: 11:00 AM - 4:00 PM'),
            leading: Icon(Icons.person, size: 40, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
