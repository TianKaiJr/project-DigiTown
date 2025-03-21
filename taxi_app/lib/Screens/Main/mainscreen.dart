import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taxi_app/Screens/Main/components/sidebar.dart';
import 'package:taxi_app/Screens/Main/components/toggle.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Main Screen')),
        body: Center(child: Text('Please log in to continue.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Main Screen')),
      drawer: SideBar(),
      body: Center(
        child:
            ToggleButton(userId: user.uid), // Only called if user is not null
      ),
    );
  }
}
