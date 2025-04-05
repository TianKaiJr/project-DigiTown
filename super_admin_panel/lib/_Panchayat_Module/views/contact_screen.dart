import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';
import 'package:super_admin_panel/___Core/Theme/app_pallete.dart';
import '../view_models/contact_view_model.dart';
import '../widgets/contact_dialog.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ContactViewModel>();

    // Fetch contact types first
    viewModel.fetchContactTypes().then((_) {
      // Automatically fetch contacts when contact types are available
      // ignore: unnecessary_null_comparison
      if (viewModel.selectedType == null && viewModel.contactTypes.isNotEmpty) {
        viewModel.selectedType = viewModel.contactTypes.first;
      }
      viewModel.fetchContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ContactViewModel>();

    return Scaffold(
      appBar: const CustomAppBar(title: "Contacts"),
      body: Column(
        children: [
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: viewModel.selectedType,
            decoration: const InputDecoration(labelText: 'Contact Type'),
            items: viewModel.contactTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              viewModel.selectedType = value ?? 'All';
              viewModel.fetchContacts();
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.contacts.isEmpty
                    ? const Center(child: Text("No contacts available"))
                    : ListView.builder(
                        itemCount: viewModel.contacts.length,
                        itemBuilder: (context, index) {
                          final contact = viewModel.contacts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            color: AppPallete.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              title: Text(contact.name),
                              subtitle: Text(contact.designation),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    viewModel.deleteContact(contact.id),
                              ),
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => ContactDialog(
                                  contact: contact,
                                  contactTypes: viewModel.contactTypes,
                                  onSave: (updatedContact, image) =>
                                      viewModel.addOrUpdateContact(
                                          updatedContact, image),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => ContactDialog(
            contactTypes: viewModel.contactTypes,
            onSave: (newContact, image) =>
                viewModel.addOrUpdateContact(newContact, image),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
