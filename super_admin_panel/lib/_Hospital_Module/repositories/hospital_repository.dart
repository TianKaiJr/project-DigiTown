import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Hospital_Module/models/hospital_option_model.dart';

class HospitalRepository {
  List<HospitalOptionModel> getOptions() {
    return [
      HospitalOptionModel(
          id: 'attendance',
          title: "Live Attendance",
          icon: Icons.event_available),
      HospitalOptionModel(
          id: 'calendar', title: "DA Calendar", icon: Icons.calendar_month),
      HospitalOptionModel(
          id: 'appointments', title: "Appointments", icon: CupertinoIcons.time),
      HospitalOptionModel(
          id: 'dept', title: "Departments", icon: Icons.business),
      HospitalOptionModel(
          id: 'addhosp', title: "Add Hospitals", icon: Icons.add),
      HospitalOptionModel(
          id: 'adddoc', title: "Add Doctors", icon: Icons.person),
    ];
  }
}
