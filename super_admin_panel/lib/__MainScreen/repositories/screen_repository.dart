import 'package:super_admin_panel/_Hospital_Module/hospital_screen.dart';
import 'package:super_admin_panel/_PalliativeCare_Module/p_screen.dart';
import 'package:super_admin_panel/_Panchayat_Module/views/panchayat_screen.dart';
import 'package:super_admin_panel/_BloodBank_Module/blood_donation_screen.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_screen.dart';
import 'package:super_admin_panel/__Dashboard/dashboard.dart';

import '../models/screen_model.dart';

class ScreenRepository {
  List<ScreenModel> getScreens() {
    return [
      ScreenModel(title: "Dashboard", screen: DashboardScreen()),
      ScreenModel(title: "Panchayat", screen: const PanchayatScreen()),
      ScreenModel(title: "Hospital", screen: const HospitalScreen()),
      ScreenModel(title: "Transport", screen: const TransportServiceScreen()),
      ScreenModel(
          title: "Palliative Care", screen: const PalliativeServiceScreen()),
      ScreenModel(title: "Blood Bank", screen: const BloodDonationScreen()),
    ];
  }

  List<String> getMenuTitles() {
    return [
      "Dashboard",
      "Panchayat",
      "Hospital",
      "Transport",
      "Palliative Care",
      "Blood Bank",
      "Profile",
      "Settings"
    ];
  }
}
