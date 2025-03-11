import 'package:flutter/material.dart';
import 'package:super_admin_panel/_PalliativeCare_Module/option_model.dart';
import 'package:super_admin_panel/_PalliativeCare_Module/p_repository.dart';

class PalliativeServiceViewModel extends ChangeNotifier {
  final PalliativeServiceRepository _repository;
  String _selectedOption = '';
  String get selectedOption => _selectedOption;

  PalliativeServiceViewModel(this._repository);

  List<PalliativeServiceOptionModel> get options => _repository.getOptions();

  void selectOption(String optionId) {
    _selectedOption = optionId;
    notifyListeners();
  }
}
