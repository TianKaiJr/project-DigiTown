import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/__BloodBank_Module/blood_donation_repository.dart';
import 'package:super_admin_panel/__BloodBank_Module/blood_donation_view_model.dart';
import 'package:super_admin_panel/__Core/Theme/app_theme.dart';
import 'package:super_admin_panel/_Hospital_Module/repositories/hospital_repository.dart';
import 'package:super_admin_panel/_Hospital_Module/view_models/doctor_attendance_view_model.dart';
import 'package:super_admin_panel/_Hospital_Module/view_models/hospital_view_model.dart';
import 'package:super_admin_panel/_Hospital_Module/views/hospital_screen.dart';
import 'package:super_admin_panel/_MainScreen_Module/repositories/screen_repository.dart';
import 'package:super_admin_panel/_MainScreen_Module/view_models/main_screen_view_model.dart';
import 'package:super_admin_panel/_MainScreen_Module/view_models/side_menu_view_model.dart';
import 'package:super_admin_panel/_MainScreen_Module/views/main_screen.dart';
import 'package:super_admin_panel/_Panchayat_Module/view_models/contact_view_model.dart';
import 'package:super_admin_panel/_Panchayat_Module/view_models/panchayat_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:super_admin_panel/ZTempModule/temp.dart';
import '__BloodBank_Module/Donor_Lists/donor_view_model.dart';
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

  @override
  Widget build(BuildContext context) {
    // Create ScreenRepository instance here
    final screenRepository = ScreenRepository();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Panel',
      theme: AppTheme.darkThemeMode,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => SideMenuViewModel(screenRepository)),
          ChangeNotifierProvider(
              create: (_) => MainScreenViewModel(screenRepository)),
          ChangeNotifierProvider(create: (_) => PanchayatViewModel()),
          ChangeNotifierProvider(create: (_) => ContactViewModel()),
          ChangeNotifierProvider(
              create: (_) => HospitalViewModel(HospitalRepository())),
          ChangeNotifierProvider(
              create: (context) => DoctorAttendanceViewModel()),
          ChangeNotifierProvider(
              create: (_) => BloodDonationViewModel(BloodDonationRepository())),
          ChangeNotifierProvider(create: (_) => DonorViewModel()),
        ],
        child: const MainScreen(),
      ),
      routes: {
        'dashboard': (context) => const TempPage(),
        'panchayat': (context) => const TempPage(),
        'hospital': (context) => const HospitalScreen(),
        'bloodBank': (context) => const TempPage(),
        'transport': (context) => const TempPage(),
        'notification': (context) => const TempPage(),
        'profile': (context) => const TempPage(),
        'settings': (context) => const TempPage(),
      },
    );
  }
}
