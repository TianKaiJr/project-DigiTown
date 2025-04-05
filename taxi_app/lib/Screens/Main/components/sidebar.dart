import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taxi_app/Screens/Requests/accept_page.dart';
import 'package:taxi_app/Screens/Requests/ride_requests_page.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String? driverId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDriverId();
  }

  Future<void> _fetchDriverId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('Driver_Users')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            driverId = querySnapshot.docs.first.id;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching driverId: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (driverId == null) {
      return const Drawer(
        child: Center(child: Text("Driver ID not found")),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Current Task'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AcceptedTaskPage(driverId: driverId!),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.request_page),
            title: const Text('Requests'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RideRequestsPage(driverId: driverId!),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/logout');
            },
          ),
        ],
      ),
    );
  }
}
