import 'package:flutter/material.dart';
import '../models/panchayat_option_model.dart';

class PanchayatViewModel with ChangeNotifier {
  String _selectedOption = '';

  final List<PanchayatOption> options = [
    PanchayatOption(
        title: "Complaints", icon: Icons.feedback_outlined, id: "complaints"),
    PanchayatOption(
        title: "Contacts", icon: Icons.contacts_outlined, id: "contacts"),
    PanchayatOption(
        title: "News & Events",
        icon: Icons.newspaper_outlined,
        id: "news_events"),
  ];

  String get selectedOption => _selectedOption;

  void selectOption(String optionId) {
    _selectedOption = optionId;
    notifyListeners();
  }
}
