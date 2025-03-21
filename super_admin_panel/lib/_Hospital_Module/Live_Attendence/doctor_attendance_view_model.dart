import 'package:flutter/material.dart';
import 'doctor_attendance_model.dart';
import 'doctor_attendance_repository.dart';

class DoctorAttendanceViewModel extends ChangeNotifier {
  final DoctorAttendanceRepository _repository = DoctorAttendanceRepository();
  List<DoctorAttendance> _doctors = [];

  List<DoctorAttendance> get doctors => _doctors;

  DoctorAttendanceViewModel() {
    fetchDoctors();
  }

  void fetchDoctors() {
    _repository.getDoctorsStream().listen((data) {
      _doctors = data;
      notifyListeners();
    });
  }

  Future<void> toggleAvailability(String id, bool isAvailable) async {
    await _repository.toggleAvailability(id, isAvailable);
    notifyListeners();
  }
}
