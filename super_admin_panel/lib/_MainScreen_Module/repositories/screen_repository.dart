import 'package:super_admin_panel/_Hospital_Module/views/hospital_screen.dart';
import 'package:super_admin_panel/_Panchayat_Module/views/panchayat_screen.dart';
import 'package:super_admin_panel/ZTempModule/temp.dart';
import 'package:super_admin_panel/_BloodBank_Module/blood_donation_screen.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_screen.dart';

import '../models/screen_model.dart';

class ScreenRepository {
  List<ScreenModel> getScreens() {
    return [
      ScreenModel(title: "Dashboard", screen: const TempPage()),
      ScreenModel(title: "Panchayat", screen: const PanchayatScreen()),
      ScreenModel(title: "Hospital", screen: const HospitalScreen()),
      ScreenModel(title: "Transport", screen: const TransportServiceScreen()),
      ScreenModel(title: "Palliative Care", screen: const TempPage()),
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
