import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/doctor_attendance_view_model.dart';
import '../widgets/doctor_attendance_dialog.dart';

class DoctorAttendanceScreen extends StatelessWidget {
  const DoctorAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DoctorAttendanceViewModel>(context);
    viewModel.fetchDoctors();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Attendance"),
        centerTitle: true,
        elevation: 5,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => DoctorAttendanceDialog(
              onSave: (doctor) => viewModel.addOrUpdateDoctor(doctor),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: viewModel.doctors.isEmpty
          ? const Center(child: Text("No doctors registered yet."))
          : ListView.builder(
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
                        const Text("Available"),
                        Switch(
                          value: doctor.status == 'Available',
                          onChanged: (value) =>
                              viewModel.toggleAvailability(doctor.id, value),
                        ),
                        const SizedBox(width: 64),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => DoctorAttendanceDialog(
                                doctor: doctor,
                                onSave: (updatedDoctor) =>
                                    viewModel.addOrUpdateDoctor(updatedDoctor),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => viewModel.deleteDoctor(doctor.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
