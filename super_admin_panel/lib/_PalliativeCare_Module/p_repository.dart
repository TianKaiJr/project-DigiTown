import 'package:flutter/material.dart';
import 'package:super_admin_panel/_PalliativeCare_Module/option_model.dart';

class PalliativeServiceRepository {
  List<PalliativeServiceOptionModel> getOptions() {
    return [
      PalliativeServiceOptionModel(
          id: 'appointments',
          title: "Appointments",
          icon: Icons.calendar_today),
    ];
  }
}
