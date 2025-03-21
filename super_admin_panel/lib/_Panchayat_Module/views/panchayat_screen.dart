import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_Panchayat_Module/Complaints/complaints.dart';
import 'package:super_admin_panel/_Panchayat_Module/view_models/panchayat_view_model.dart';
import 'package:super_admin_panel/_Panchayat_Module/views/contact_screen.dart';
import 'package:super_admin_panel/_Panchayat_Module/views/news_events_screen.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/pm_header.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/panchayat_option_box.dart';

class PanchayatScreen extends StatelessWidget {
  const PanchayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Row(children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                const PMHeader(
                  name: "Panchayat",
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: context
                      .watch<PanchayatViewModel>()
                      .options
                      .map(
                        (option) => PanchayatOptionBox(
                          title: option.title,
                          icon: option.icon,
                          onTap: () {
                            context
                                .read<PanchayatViewModel>()
                                .selectOption(option.id);
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin:
                const EdgeInsets.all(16.0), // Add margin around the container
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.4), // Border color
                width: 1.5, // Border width
              ),
              borderRadius: BorderRadius.circular(
                  12.0), // Rounded corners for the container
            ),
            child: _getSelectedScreen(
              context.watch<PanchayatViewModel>().selectedOption,
            ),
          ),
        )
      ])),
    );
  }

  Widget _getSelectedScreen(String optionId) {
    switch (optionId) {
      case 'complaints':
        return const ComplaintListPage();
      case 'contacts':
        return const ContactScreen();
      case 'news_events':
        return const NewsEventsScreen();
      default:
        return const Center(
          child: Text('Please select an option to view details'),
        );
    }
  }
}
