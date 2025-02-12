import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/__BloodBank_Module/blood_donation_option_model.dart';

class BloodDonationRepository {
  List<BloodDonationOptionModel> getOptions() {
    return [
      BloodDonationOptionModel(
          id: 'donors', title: "Donors List", icon: Icons.people),
      BloodDonationOptionModel(
          id: 'requests', title: "Blood Requests", icon: Icons.bloodtype),
      BloodDonationOptionModel(
          id: 'history', title: "Donation History", icon: CupertinoIcons.time),
    ];
  }
}
