import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/ZTempModule/temp.dart';
import 'package:super_admin_panel/_BloodBank_Module/Blood_Requests/blood_screens.dart';
import 'package:super_admin_panel/_BloodBank_Module/Donor_Lists/donor_screen.dart';
import 'package:super_admin_panel/_BloodBank_Module/blood_donation_header.dart';
import 'package:super_admin_panel/_BloodBank_Module/blood_donation_view_model.dart';
import 'package:super_admin_panel/_BloodBank_Module/option_box.dart';

class BloodDonationScreen extends StatelessWidget {
  const BloodDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BloodDonationViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Left side: Option Boxes
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BloodDonationHeader(name: "Blood Donation"),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: viewModel.options.map((option) {
                        return OptionBox(
                          title: option.title,
                          icon: option.icon,
                          onTap: () => viewModel.selectOption(option.id),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Right side: Preview content based on selected option
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: viewModel.selectedOption.isEmpty
                    ? const Center(
                        child: Text(
                          'Please select an option to view details',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : _getScreen(viewModel.selectedOption),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getScreen(String option) {
    switch (option) {
      case 'donors':
        return const DonorScreen();
      case 'requests':
        return const BloodRequestsScreen();
      case 'history':
        return const TempPage();
      default:
        return const Center(
          child: Text(
            'Invalid option selected',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        );
    }
  }
}

/*
      case 'donors':
        return const DonorListScreen();
      case 'requests':
        return const BloodRequestScreen();
      case 'history':
        return const DonationHistoryScreen();
*/
