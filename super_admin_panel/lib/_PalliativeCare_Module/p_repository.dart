import 'package:flutter/material.dart';
import 'package:super_admin_panel/_PalliativeCare_Module/option_model.dart';

class PalliativeServiceRepository {
  List<PalliativeServiceOptionModel> getOptions() {
    return [
      PalliativeServiceOptionModel(
          id: 'appointments',
          title: "Appointments",
          icon: Icons.calendar_today),
      PalliativeServiceOptionModel(
          id: 'drugbank',
          title: "Medicine Usage Finder",
          icon: Icons.find_in_page),
      PalliativeServiceOptionModel(
          id: 'healthnews', title: "Health News", icon: Icons.newspaper),
    ];
  }
}
