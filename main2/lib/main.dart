import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:main2/__Auth/auth_page.dart';
import 'package:main2/___Core/Theme/app_theme.dart';
import 'package:main2/firebase_options.dart';

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
      theme: AppTheme.darkThemeMode,
      // darkTheme: AppTheme.darkThemeMode,
      // themeMode: ThemeMode.system,
      routes: {
        // 'x': (context) => const ProfilePage(),
        // 'y': (context) => const BookingAppointment(
        //       hospitalId: '',
        //       hospitalName: '',
        //       departments: [],
        //     ),
      },
      title: 'Login',
      home: const AuthWrapper(),
    );
  }
}
