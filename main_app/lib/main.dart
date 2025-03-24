import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:main_app/firebase_options.dart';
import 'package:main_app/home.dart';
import 'booking_appoinment.dart';
import 'profile_page.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // For Android, webview_flutter 4.10.0 automatically selects the correct implementation,
  // so you don't need to set WebView.platform manually.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //theme: FlexThemeData.light(scheme: FlexScheme.barossa),
      //darkTheme: FlexThemeData.dark(scheme: FlexScheme.barossa),
      //themeMode: ThemeMode.system,
      routes: {
        'x': (context) => const ProfilePage(),
        'y': (context) => const BookingAppointment(
              hospitalId: '',
              hospitalName: '',
              departments: [],
            ),
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
    // Listen to Firebase auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // If the user is authenticated, navigate to your landing page (adjust as needed)
        if (snapshot.hasData) {
          return const HomePage();
        }
        // Otherwise, show the login page
        return LoginPage();
      },
    );
  }
}
