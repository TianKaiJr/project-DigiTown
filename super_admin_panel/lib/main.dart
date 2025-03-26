import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_BloodBank_Module/blood_donation_repository.dart';
import 'package:super_admin_panel/_BloodBank_Module/blood_donation_view_model.dart';
import 'package:super_admin_panel/_PalliativeCare_Module/p_repository.dart';
import 'package:super_admin_panel/_PalliativeCare_Module/p_view_model.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_repository.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_view_model.dart';
import 'package:super_admin_panel/__Auth/auth_page.dart';
import 'package:super_admin_panel/__Settings/restart.dart';
import 'package:super_admin_panel/___Core/RBAC/role_bloc.dart';
import 'package:super_admin_panel/___Core/Theme/app_theme.dart';
import 'package:super_admin_panel/_Hospital_Module/hospital_repository.dart';
import 'package:super_admin_panel/_Hospital_Module/Live_Attendence/doctor_attendance_view_model.dart';
import 'package:super_admin_panel/_Hospital_Module/hospital_view_model.dart';
// import 'package:super_admin_panel/_Hospital_Module/hospital_screen.dart';
import 'package:super_admin_panel/__MainScreen/repositories/screen_repository.dart';
import 'package:super_admin_panel/__MainScreen/view_models/main_screen_view_model.dart';
import 'package:super_admin_panel/__MainScreen/view_models/side_menu_view_model.dart';
import 'package:super_admin_panel/_Panchayat_Module/view_models/contact_view_model.dart';
import 'package:super_admin_panel/_Panchayat_Module/view_models/panchayat_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import '_BloodBank_Module/Donor_Lists/donor_view_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  runApp(const RestartWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screenRepository = ScreenRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RoleBloc()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => SideMenuViewModel(screenRepository)),
          ChangeNotifierProvider(
              create: (context) =>
                  MainScreenViewModel(screenRepository, context)),
          ChangeNotifierProvider(create: (_) => PanchayatViewModel()),
          ChangeNotifierProvider(create: (_) => ContactViewModel()),
          ChangeNotifierProvider(
              create: (_) => HospitalViewModel(HospitalRepository())),
          ChangeNotifierProvider(
              create: (context) => DoctorAttendanceViewModel()),
          ChangeNotifierProvider(
              create: (_) => BloodDonationViewModel(BloodDonationRepository())),
          ChangeNotifierProvider(create: (_) => DonorViewModel()),
          ChangeNotifierProvider(
              create: (_) =>
                  TransportServiceViewModel(TransportServiceRepository())),
          ChangeNotifierProvider(
              create: (_) =>
                  PalliativeServiceViewModel(PalliativeServiceRepository())),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Admin Panel',
          theme: AppTheme.darkThemeMode,
          home: const AuthPage(),
        ),
      ),
    );
  }
}
