import 'package:flutter/material.dart';
import 'package:main_app/components/custom_IconButton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_appoinment.dart';
import 'NoInternetComponent/Utils/network_utils.dart';

class HospitalPage extends StatefulWidget {
  const HospitalPage({Key? key}) : super(key: key);

  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  // Updated types to List<Map<String, dynamic>>
  List<Map<String, dynamic>> hospitals = [];
  List<Map<String, dynamic>> filteredHospitals = [];

  final TextEditingController _searchController = TextEditingController();

  final List<String> healthTips = [
    'Drink plenty of water to stay hydrated.',
    'Get at least 7-8 hours of sleep daily.',
    'Wash your hands regularly to avoid infections.',
    'Exercise for at least 30 minutes a day.',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch hospitals from Firestore on startup
    _fetchHospitals();
    // Listen for search-bar changes
    _searchController.addListener(_filterHospitals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch hospital data from the 'Hospitals' collection in Firestore
  /// and also look up each department's name from 'Hospital_Departments'.
  Future<void> _fetchHospitals() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Hospitals').get();

      final List<Map<String, dynamic>> fetchedHospitals = [];

      // Process each hospital document
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert the raw Firestore array to List<String> safely
        final List<String> departmentIds = (data['Departments'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() 
            ?? <String>[];

        // For each department doc ID, fetch the 'Hospital_Departments' doc
        final deptDocs = await Future.wait(
          departmentIds.map((deptId) =>
            FirebaseFirestore.instance
              .collection('Hospital_Departments')
              .doc(deptId)
              .get()
          ),
        );

        // Convert each fetched doc into a department name
        final List<String> departmentNames = deptDocs.map<String>((d) {
          if (d.exists) {
            final deptData = d.data();
            return deptData?['name'] ?? 'Unknown Department';
          }
          return 'Unknown Department';
        }).toList();

        fetchedHospitals.add({
          'id': doc.id, // Store the hospital doc ID
          'name': data['Name']?.toString() ?? '',
          'address': data['Address']?.toString() ?? '',
          'phone': data['Phone']?.toString() ?? '',
          // Instead of storing raw IDs, we now store the actual department names:
          'departments': departmentNames,
        });
      }

      setState(() {
        hospitals = fetchedHospitals;
        filteredHospitals = fetchedHospitals;
      });
    } catch (e) {
      debugPrint('Error fetching hospitals: $e');
    }
  }

  /// Filter hospitals based on search text
  void _filterHospitals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredHospitals = hospitals.where((hospital) {
        final name = (hospital['name'] ?? '') as String;
        final address = (hospital['address'] ?? '') as String;
        return name.toLowerCase().contains(query) ||
               address.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// Launch phone dialer
  void _launchCaller(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Launch Google Maps for the given address
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Services'),
      ),
      body: ListView(
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

          /// Search Bar
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

          /// Hospital List
          ...filteredHospitals.map(
            (hospital) => Card(
              child: ListTile(
                title: Row(
                  children: [
                    /// Hospital Name (Expanded so it won't get truncated)
                    Expanded(
                      child: Text(
                        hospital['name'] ?? 'Unknown Hospital',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    /// Book Now Button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingAppointment(
                            hospitalId: hospital['id'],
                            hospitalName: hospital['name'],
                            departments: hospital['departments'],
                          ),
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                    const SizedBox(width: 6),

                    /// Call Icon
                    IconButton(
                      icon: const Icon(Icons.phone, size: 20, color: Colors.blue),
                      onPressed: () => _launchCaller(hospital['phone'] ?? ''),
                      tooltip: 'Call',
                    ),

                    /// Location Icon
                    IconButton(
                      icon: const Icon(Icons.map, size: 20, color: Colors.blue),
                        onPressed: () {
                          NetworkUtils.checkAndProceed(context, () {
                            _launchMaps(hospital['address'] ?? '');
                          });
                        },
                      tooltip: 'Location',
                    ),


                    /// Facilities Icon
                    IconButton(
                      icon: const Icon(Icons.business, size: 20, color: Colors.blue),
                      onPressed: () {
                        // TODO: Implement "Facilities" action
                      },
                      tooltip: 'Facilities',
                    ),
                  ],
                ),
                subtitle: Text(hospital['address'] ?? ''),
              ),
            ),
          ),

          const SizedBox(height: 20.0),

          /// Location and Navigation
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
                NetworkUtils.checkAndProceed(context, () {
                  _launchMaps('hospitals near me');
                });
              },

            ),
          ),

          const SizedBox(height: 20.0),

          /// Health Tips
          const Text(
            'Health Tips',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          ...healthTips.map(
            (tip) => ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(tip),
            ),
          ),
        ],
      ),
    );
  }
}
