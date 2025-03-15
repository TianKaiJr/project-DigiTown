import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';
import 'doctor_attendance_view_model.dart';

class DoctorAttendanceScreen extends StatelessWidget {
  const DoctorAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Doctor Attendance"),
      body: Consumer<DoctorAttendanceViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.doctors.isEmpty) {
            return const Center(child: Text("No doctors registered yet."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.doctors.length,
            itemBuilder: (context, index) {
              final doctor = viewModel.doctors[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 5,
                child: ListTile(
                  title: Text(doctor.name),
                  subtitle: Text(doctor.designation),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(doctor.status),
                      Switch(
                        value: doctor.status == 'Available',
                        onChanged: (value) =>
                            viewModel.toggleAvailability(doctor.id, value),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
