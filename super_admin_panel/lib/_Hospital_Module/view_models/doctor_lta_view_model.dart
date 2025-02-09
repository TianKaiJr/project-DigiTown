import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/doctor_lta_model.dart';
import '../repositories/doctor_lta_repository.dart';

class DoctorLTAViewModel extends ChangeNotifier {
  final DoctorLTARepository _repository = DoctorLTARepository();

  List<Map<String, String>> doctors = [];
  String? selectedDoctorId;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  Map<DateTime, bool> availabilityMap = {};

  Future<void> fetchDoctors() async {
    doctors = await _repository.fetchDoctors();
    notifyListeners();
  }

  Future<void> fetchAvailability(String doctorId) async {
    selectedDoctorId = doctorId;
    DoctorLTA? doctorLTA = await _repository.fetchAvailability(doctorId);
    availabilityMap = doctorLTA?.availability ?? {};
    notifyListeners();
  }

  void toggleAvailability(DateTime day) {
    availabilityMap[day] = !(availabilityMap[day] ?? false);
    notifyListeners();
  }

  Future<void> saveAvailability(BuildContext context) async {
    if (selectedDoctorId == null) return;
    await _repository.saveAvailability(selectedDoctorId!, availabilityMap);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Availability saved successfully!')),
    );
  }

  void updateCalendarFormat(CalendarFormat format) {
    calendarFormat = format;
    notifyListeners();
  }

  void updateFocusedDay(DateTime day) {
    focusedDay = day;
    notifyListeners();
  }

  void updateSelectedDay(DateTime day) {
    selectedDay = day;
    notifyListeners();
  }
}
