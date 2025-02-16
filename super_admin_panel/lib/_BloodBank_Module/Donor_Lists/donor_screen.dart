import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_BloodBank_Module/Donor_Lists/appbar_blood.dart';
import 'donor_view_model.dart';
import 'donor_dialog.dart';

class DonorScreen extends StatefulWidget {
  final bool enableWriteMode; // Added mode toggle

  const DonorScreen({super.key, this.enableWriteMode = true}); // Default: true

  @override
  State<DonorScreen> createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  String? selectedSort;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DonorViewModel>().fetchDonors());
  }

  @override
  Widget build(BuildContext context) {
    final donorVM = context.watch<DonorViewModel>();

    return Scaffold(
      appBar: CustomBloodAppBar(
        title: "Donor List",
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_outlined),
            onSelected: (String value) {
              setState(() {
                selectedSort = value;
                donorVM.sortDonors(value);
              });
            },
            itemBuilder: (context) => [
              "Name (A-Z)",
              "Name (Z-A)",
              "Age (Ascending)",
              "Age (Descending)",
              "Blood Type (A → O)",
              "Blood Type (O → A)",
              "Last Donation (Recent)",
              "Last Donation (Oldest)",
              "Eligibility (Eligible First)",
              "Eligibility (Not Eligible First)",
            ].map((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: donorVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : donorVM.donors.isEmpty
              ? const Center(child: Text("No donors available"))
              : ListView.builder(
                  itemCount: donorVM.donors.length,
                  itemBuilder: (context, index) {
                    final donor = donorVM.donors[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(donor.name),
                          subtitle: Text(
                              "${donor.age} years | ${donor.bloodType} | ${donor.address}"),
                          // ignore: unnecessary_null_comparison
                          trailing: donor.lastDonationDate != null
                              ? Text(
                                  "${DateTime.now().difference(donor.lastDonationDate).inDays ~/ 7} weeks ago",
                                )
                              : const Icon(Icons.not_interested,
                                  color: Colors.red),
                        ),
                        if (index < donorVM.donors.length - 1) const Divider(),
                      ],
                    );
                  },
                ),
      floatingActionButton: widget.enableWriteMode
          ? FloatingActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => DonorDialog(
                  onSave: (newDonor) {
                    donorVM.addDonor(newDonor);
                    setState(() {});
                  },
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null, // Hide FAB if enableWriteMode is false
    );
  }
}
