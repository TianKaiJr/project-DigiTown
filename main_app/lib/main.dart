import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:main_app/firebase_options.dart';
import 'booking_appoinment.dart';
import 'profile_page.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        'x': (context) => const ProfilePage(),
        'y': (context) => const BookingAppointment(),
      },
      title: 'Login',
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in by listening to Firebase auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While the connection is loading, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // If the user is authenticated, navigate to the profile page (or any other page)
        if (snapshot.hasData) {
          return LoginPage();  // Adjust to your authenticated landing page
        }
        
        // If the user is not authenticated, navigate to the login page
        return LoginPage();  // Adjust to your login page
      },
    );
  }
}
