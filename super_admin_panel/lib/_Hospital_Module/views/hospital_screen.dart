import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/ZTempModule/hospital_appointments.dart';
import 'package:super_admin_panel/_Hospital_Module/Add_Departments/hospital_dept.dart';
import 'package:super_admin_panel/_Hospital_Module/Add_Hospitals/add_hospitals.dart';
import 'package:super_admin_panel/_Hospital_Module/view_models/hospital_view_model.dart';
import 'package:super_admin_panel/_Hospital_Module/views/doctor_attendance_screen.dart';
import 'package:super_admin_panel/_Hospital_Module/views/doctor_lta_screen.dart';
import 'package:super_admin_panel/_Hospital_Module/widgets/hospital_header.dart';
import 'package:super_admin_panel/_Hospital_Module/widgets/option_box.dart';

class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HospitalViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Left side: Option Boxes
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HospitalHeader(name: "Hospital"),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: viewModel.options.map((option) {
                        return OptionBox(
                          title: option.title,
                          icon: option.icon,
                          onTap: () => viewModel.selectOption(option.id),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Right side: Preview content based on selected option
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(
                    16.0), // Add margin around the container
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.4), // Border color
                    width: 1.5, // Border width
                  ),
                  borderRadius: BorderRadius.circular(
                      12.0), // Rounded corners for the container
                ),
                child: viewModel.selectedOption.isEmpty
                    ? const Center(
                        child: Text(
                          'Please select an option to view details',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : _getScreen(viewModel.selectedOption),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getScreen(String option) {
    switch (option) {
      case 'attendance':
        return const DoctorAttendanceScreen();
      case 'appointments':
        return const AppointmentListPage();
      case 'calendar':
        return const DoctorLTAScreen();
      case 'dept':
        return const HospitalDepartmentsScreen();
      case 'addhosp':
        return const AddHospitalsScreen();
      default:
        return const Center(
          child: Text(
            'Invalid option selected',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        );
    }
  }
}
