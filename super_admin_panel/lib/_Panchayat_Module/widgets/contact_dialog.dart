import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/contact_model.dart';

class ContactDialog extends StatefulWidget {
  final ContactModel? contact;
  final List<String> contactTypes;
  final Function(ContactModel, File?) onSave;

  const ContactDialog(
      {this.contact,
      required this.contactTypes,
      required this.onSave,
      super.key});

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  final nameController = TextEditingController();
  final designationController = TextEditingController();
  final numberController = TextEditingController();
  String selectedType = '';
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      nameController.text = widget.contact!.name;
      designationController.text = widget.contact!.designation;
      numberController.text = widget.contact!.number;
      selectedType = widget.contact!.contactType;
    } else if (widget.contactTypes.isNotEmpty) {
      selectedType = widget.contactTypes[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'New Contact' : 'Edit Contact'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null && result.files.single.path != null) {
                  selectedImage = File(result.files.single.path!);
                  setState(() {});
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : (widget.contact?.imageUrl.isNotEmpty ?? false
                        ? NetworkImage(widget.contact!.imageUrl)
                        : null) as ImageProvider?,
                child:
                    selectedImage == null ? const Icon(Icons.camera_alt) : null,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(
              height: 10,
            ),
            TextField(
                controller: designationController,
                decoration: const InputDecoration(labelText: 'Designation')),
            const SizedBox(
              height: 10,
            ),
            TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Phone Number')),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              value: selectedType.isEmpty
                  ? "All"
                  : selectedType, // Use null if empty
              items: widget.contactTypes
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value ?? ''; // Update selectedType
                });
              },
              decoration: const InputDecoration(labelText: 'Contact Type'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final contact = ContactModel(
              id: widget.contact?.id ?? '',
              name: nameController.text,
              designation: designationController.text,
              number: numberController.text,
              imageUrl: widget.contact?.imageUrl ?? '',
              contactType: selectedType,
            );
            widget.onSave(contact, selectedImage);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
