import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_app/Screens/OneTimeProfile/profile_data_page.dart';
import '../screens/Main/mainscreen.dart';
import '../screens/Login/login_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("Driver_Users")
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                return MainScreen(); // Profile exists, go to main screen
              } else {
                return ProfileDataPage(); // No profile, go to profile entry page
              }
            },
          );
        } else {
          return LoginScreen(); // User not logged in
        }
      },
    );
  }
}
