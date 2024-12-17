import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_Hospital_Module/view_models/hospital_view_model.dart';
import 'package:super_admin_panel/_Hospital_Module/widgets/hospital_header.dart';
import 'package:super_admin_panel/_Hospital_Module/widgets/option_box.dart';
import 'package:super_admin_panel/ZTemporary/screens/hospital/screens/appointment_screen.dart';
import 'package:super_admin_panel/ZTemporary/screens/hospital/screens/attendence_screen.dart';
import 'package:super_admin_panel/ZTemporary/screens/hospital/screens/calender_screen.dart';

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
                    const HospitalHeader(),
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
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _getScreen(String option) {
    switch (option) {
      case 'attendance':
        return const AttendanceScreen();
      case 'appointments':
        return const AppointmentsScreen();
      case 'calendar':
        return CalendarScreen();
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
