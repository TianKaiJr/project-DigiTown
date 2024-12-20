import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../repositories/doctor_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final DoctorRepository _doctorRepository;

  CalendarViewModel(this._doctorRepository);

  List<Doctor> _doctors = [];
  List<Doctor> get doctors => _doctors;

  String? _selectedDoctorId;
  String? get selectedDoctorId => _selectedDoctorId;

  Map<DateTime, bool> _availabilityMap = {};
  Map<DateTime, bool> get availabilityMap => _availabilityMap;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchDoctors() async {
    _doctors = await _doctorRepository.fetchDoctors();
    notifyListeners();
  }

  void selectDoctor(String doctorId) {
    _selectedDoctorId = doctorId;
    notifyListeners();
    fetchAvailability();
  }

  Future<void> fetchAvailability() async {
    if (_selectedDoctorId == null) return;

    _isLoading = true;
    notifyListeners();

    _availabilityMap =
        await _doctorRepository.fetchAvailability(_selectedDoctorId!);

    _isLoading = false;
    notifyListeners();
  }

  void toggleAvailability(DateTime day) {
    _availabilityMap[day] = !(_availabilityMap[day] ?? false);
    notifyListeners();
  }

  Future<void> saveAvailability() async {
    if (_selectedDoctorId == null) return;

    await _doctorRepository.saveAvailability(
        _selectedDoctorId!, _availabilityMap);
  }
}
