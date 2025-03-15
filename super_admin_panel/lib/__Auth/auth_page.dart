import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/__Auth/Login/login_page.dart';
import 'package:super_admin_panel/__MainScreen/views/main_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainScreen(); // User is logged in
        } else {
          return const DarkLoginScreen(); // User is not logged in
        }
      },
    );
  }
}
