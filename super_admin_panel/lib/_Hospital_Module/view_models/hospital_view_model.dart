import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Hospital_Module/models/hospital_option_model.dart';
import 'package:super_admin_panel/_Hospital_Module/repositories/hospital_repository.dart';

class HospitalViewModel extends ChangeNotifier {
  final HospitalRepository _repository;
  String _selectedOption = '';
  String get selectedOption => _selectedOption;

  HospitalViewModel(this._repository);

  List<HospitalOptionModel> get options => _repository.getOptions();

  void selectOption(String optionId) {
    _selectedOption = optionId;
    notifyListeners();
  }
}
