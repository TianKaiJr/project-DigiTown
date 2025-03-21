import 'package:flutter/material.dart';
import 'donor_model.dart';
import 'donor_repository.dart';

class DonorViewModel extends ChangeNotifier {
  final DonorRepository _repository = DonorRepository();
  List<Donor> donors = [];
  bool isLoading = false;

  Future<void> fetchDonors() async {
    isLoading = true;
    notifyListeners();

    donors = await _repository.getDonors();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addDonor(Donor donor) async {
    await _repository.addDonor(donor);
    await fetchDonors();
  }

  void sortDonors(String? sortBy) {
    if (sortBy == null) return;

    switch (sortBy) {
      case "Name (A-Z)":
        donors.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "Name (Z-A)":
        donors.sort((a, b) => b.name.compareTo(a.name));
        break;
      case "Age (Ascending)":
        donors.sort((a, b) => a.age.compareTo(b.age));
        break;
      case "Age (Descending)":
        donors.sort((a, b) => b.age.compareTo(a.age));
        break;
      case "Blood Type (A → O)":
        donors.sort((a, b) => a.bloodType.compareTo(b.bloodType));
        break;
      case "Blood Type (O → A)":
        donors.sort((a, b) => b.bloodType.compareTo(a.bloodType));
        break;
      case "Last Donation (Recent)":
        donors.sort((a, b) => b.lastDonationDate.compareTo(a.lastDonationDate));
        break;
      case "Last Donation (Oldest)":
        donors.sort((a, b) => a.lastDonationDate.compareTo(b.lastDonationDate));
        break;
      case "Eligibility (Eligible First)":
        donors.sort((a, b) => b.eligibilityStatus ? 1 : -1);
        break;
      case "Eligibility (Not Eligible First)":
        donors.sort((a, b) => a.eligibilityStatus ? 1 : -1);
        break;
    }

    notifyListeners();
  }
}
