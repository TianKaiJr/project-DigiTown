import 'package:flutter/material.dart';
import 'package:super_admin_panel/_BloodBank_Module/blood_donation_option_model.dart';
import 'package:super_admin_panel/_BloodBank_Module/blood_donation_repository.dart';

class BloodDonationViewModel extends ChangeNotifier {
  final BloodDonationRepository _repository;
  String _selectedOption = '';
  String get selectedOption => _selectedOption;

  BloodDonationViewModel(this._repository);

  List<BloodDonationOptionModel> get options => _repository.getOptions();

  void selectOption(String optionId) {
    _selectedOption = optionId;
    notifyListeners();
  }
}
