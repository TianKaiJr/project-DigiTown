import 'package:flutter/material.dart';
import 'doctor_attendance_model.dart';
import 'doctor_attendance_repository.dart';

class DoctorAttendanceViewModel extends ChangeNotifier {
  final DoctorAttendanceRepository _repository = DoctorAttendanceRepository();
  List<DoctorAttendance> _doctors = [];

  List<DoctorAttendance> get doctors => _doctors;

  void fetchDoctors() {
    _repository.getDoctorsStream().listen((data) {
      _doctors = data;
      notifyListeners();
    });
  }

  Future<void> addOrUpdateDoctor(DoctorAttendance doctor) async {
    await _repository.addOrUpdateDoctor(doctor);
  }

  Future<void> deleteDoctor(String id) async {
    await _repository.deleteDoctor(id);
  }

  Future<void> toggleAvailability(String id, bool isAvailable) async {
    await _repository.toggleAvailability(id, isAvailable);
  }
}
