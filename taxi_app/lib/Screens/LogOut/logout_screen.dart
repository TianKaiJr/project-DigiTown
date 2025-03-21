import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogOutPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LogOutPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      // Navigate to the login page after logout
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Out'),
        centerTitle: true, // Centers title in AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centers content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centers content horizontally
          children: [
            Text(
              user != null
                  ? "Logged in as: ${user.email}"
                  : "No user logged in",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ElevatedButton(
                onPressed: () => _signOut(context),
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
