import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/constants.dart';
import 'package:super_admin_panel/controllers/menu_app_controller.dart';
import 'package:super_admin_panel/screens/dashboard/dashboard_screen.dart';
import 'package:super_admin_panel/screens/hospital/hospital_screen.dart';
import 'package:super_admin_panel/screens/main/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Panel',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuAppController(),
          ),
        ],
        child: const MainScreen(),
      ),
      routes: {
        'dashboard': (context) => const DashboardScreen(),
        // 'panchayat': (context) => const PanchayatScreen(),
        'hospital': (context) => const HospitalScreen(),
        // 'bloodBank': (context) => const BloodBankScreen(),
        // 'transport': (context) => const TransportScreen(),
        // 'notification': (context) => const NotificationScreen(),
        // 'profile': (context) => const ProfileScreen(),
        // 'settings': (context) => const SettingsScreen(),
      },
    );
  }
}
