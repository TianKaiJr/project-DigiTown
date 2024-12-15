import 'package:flutter/material.dart';
import 'package:main_app/booking_appoinment.dart';
import 'package:main_app/profile_page.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        'x': (context) => const ProfilePage(),
        'y':(context) => const BookingAppoinment(),
        
      },
      title: 'Login',
      home: LoginPage(),
    );
  }
}

