import 'package:super_admin_panel/_Hospital_Module/views/hospital_screen.dart';
import 'package:super_admin_panel/_Panchayat_Module/views/panchayat_screen.dart';
import 'package:super_admin_panel/ZTempModule/temp.dart';

import '../models/screen_model.dart';

class ScreenRepository {
  List<ScreenModel> getScreens() {
    return [
      ScreenModel(title: "Dashboard", screen: const TempPage()),
      ScreenModel(title: "Panchayat", screen: const PanchayatScreen()),
      ScreenModel(title: "Hospital", screen: const HospitalScreen()),
    ];
  }

  List<String> getMenuTitles() {
    return ["Dashboard", "Panchayat", "Hospital", "Profile", "Settings"];
  }
}
