import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_option_model.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_repository.dart';

class TransportServiceViewModel extends ChangeNotifier {
  final TransportServiceRepository _repository;
  String _selectedOption = '';
  String get selectedOption => _selectedOption;

  TransportServiceViewModel(this._repository);

  List<TransportServiceOptionModel> get options => _repository.getOptions();

  void selectOption(String optionId) {
    _selectedOption = optionId;
    notifyListeners();
  }
}
