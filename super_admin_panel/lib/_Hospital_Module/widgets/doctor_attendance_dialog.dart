import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/doctor_attendance_model.dart';

class DoctorAttendanceDialog extends StatefulWidget {
  final DoctorAttendance? doctor;
  final Function(DoctorAttendance) onSave;

  const DoctorAttendanceDialog({super.key, this.doctor, required this.onSave});

  @override
  _DoctorAttendanceDialogState createState() => _DoctorAttendanceDialogState();
}

class _DoctorAttendanceDialogState extends State<DoctorAttendanceDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _nameController.text = widget.doctor!.name;
      _designationController.text = widget.doctor!.designation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.doctor == null ? "Add Doctor" : "Edit Doctor"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name")),
          TextField(
              controller: _designationController,
              decoration: const InputDecoration(labelText: "Designation")),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _designationController.text.isNotEmpty) {
              widget.onSave(DoctorAttendance(
                id: widget.doctor?.id ?? _nameController.text,
                name: _nameController.text,
                designation: _designationController.text,
                status: 'Available',
                timestamp:
                    DateFormat('yyyy MM dd HH:mm').format(DateTime.now()),
              ));
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.doctor == null ? "Add" : "Update"),
        ),
      ],
    );
  }
}
