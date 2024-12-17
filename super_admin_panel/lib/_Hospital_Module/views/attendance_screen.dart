import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_Hospital_Module/view_models/doctor_attendence_view_model.dart';
import 'package:super_admin_panel/_Hospital_Module/widgets/doctor_attendence_dialog.dart';

class AttendanceScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DoctorAttendenceViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Attendance"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nameController.clear();
          _designationController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return DoctorAttendenceDialog(
                nameController: _nameController,
                designationController: _designationController,
                onSave: () {
                  viewModel.addOrUpdateDoctor(
                    name: _nameController.text,
                    designation: _designationController.text,
                  );
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: viewModel.doctors.length,
              itemBuilder: (context, index) {
                final doctor = viewModel.doctors[index];

                return Card(
                  child: ListTile(
                    title: Text(doctor.name),
                    subtitle: Text(doctor.designation),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: doctor.status == 'Available',
                          onChanged: (value) {
                            viewModel.toggleAvailability(doctor.id, value);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _nameController.text = doctor.name;
                            _designationController.text = doctor.designation;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return DoctorAttendenceDialog(
                                  nameController: _nameController,
                                  designationController: _designationController,
                                  onSave: () {
                                    viewModel.addOrUpdateDoctor(
                                      id: doctor.id,
                                      name: _nameController.text,
                                      designation: _designationController.text,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            viewModel.deleteDoctor(doctor.id);
                          },
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
