import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/___Core/Theme/app_pallete.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';
import '../view_models/contact_view_model.dart';
import '../widgets/contact_dialog.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ContactViewModel>();

    // Fetch contact types on initial load if not done already
    if (viewModel.contactTypes.isEmpty) {
      viewModel.fetchContactTypes();
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "Contacts"),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          DropdownButtonFormField<String>(
            value: viewModel.selectedType,
            decoration: const InputDecoration(
              labelText: 'Contact Type', // Label text like TextField
            ),
            items: viewModel.contactTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              viewModel.selectedType = value ?? 'All';
              viewModel.fetchContacts(); // Re-fetch contacts on type change
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: viewModel.contacts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: viewModel.contacts.length,
                      itemBuilder: (context, index) {
                        final contact = viewModel.contacts[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0), // Add margin for spacing
                          decoration: BoxDecoration(
                            color:
                                AppPallete.secondaryColor, // Background color
                            borderRadius:
                                BorderRadius.circular(12.0), // Rounded corners
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16), // Padding inside the box
                            title: Text(contact.name),
                            subtitle: Text(contact.designation),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  viewModel.deleteContact(contact.id),
                            ),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => ContactDialog(
                                contact: contact,
                                contactTypes: viewModel.contactTypes,
                                onSave: (updatedContact, image) => viewModel
                                    .addOrUpdateContact(updatedContact, image),
                              ),
                            ),
                          ),
                        );
                      },
                    )),
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
