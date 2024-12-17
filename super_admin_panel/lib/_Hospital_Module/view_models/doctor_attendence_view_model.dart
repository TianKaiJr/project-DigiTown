import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:super_admin_panel/_Hospital_Module/models/doctor_attendence_model.dart';
import 'package:super_admin_panel/_Hospital_Module/repositories/doctor_attendence_repository.dart';

class DoctorAttendenceViewModel extends ChangeNotifier {
  final DoctorAttendenceRepository _repository = DoctorAttendenceRepository();

  List<DoctorAttendence> _doctors = [];
  List<DoctorAttendence> get doctors => _doctors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void fetchDoctors() {
    _repository.fetchDoctors().listen((doctors) {
      _doctors = doctors;
      notifyListeners();
    });
  }

  Future<void> addOrUpdateDoctor(
      {String? id, required String name, required String designation}) async {
    final String timestamp =
        DateFormat('yyyy MM dd HH:mm').format(DateTime.now());
    final doctor = DoctorAttendence(
      id: id ?? '',
      name: name,
      designation: designation,
      status: 'Available',
      timestamp: timestamp,
    );

    if (id == null) {
      await _repository.addDoctor(doctor);
    } else {
      await _repository.updateDoctor(id, doctor);
    }
  }

  Future<void> deleteDoctor(String id) async {
    await _repository.deleteDoctor(id);
  }

  Future<void> toggleAvailability(String id, bool isAvailable) async {
    final String timestamp =
        DateFormat('yyyy MM dd HH:mm').format(DateTime.now());
    await _repository.toggleAvailability(id, isAvailable, timestamp);
  }
}
