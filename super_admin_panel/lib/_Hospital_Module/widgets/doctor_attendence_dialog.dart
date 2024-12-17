import 'package:flutter/material.dart';

class DoctorAttendenceDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController designationController;
  final VoidCallback onSave;

  const DoctorAttendenceDialog({
    required this.nameController,
    required this.designationController,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add/Edit Doctor"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: designationController,
            decoration: const InputDecoration(labelText: "Designation"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: onSave,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
