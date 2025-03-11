import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/ZTempModule/temp.dart';
import 'package:super_admin_panel/_Transport_Module/Taxi_Service/taxi_service.dart';
import 'package:super_admin_panel/_Transport_Module/option_box.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_header.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_view_model.dart';

class TransportServiceScreen extends StatelessWidget {
  const TransportServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransportServiceViewModel>();

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
                    const TransportServiceHeader(name: "Transport Service"),
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
      case 'taxi':
        return const TaxiServiceScreen();
      case 'routes':
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
