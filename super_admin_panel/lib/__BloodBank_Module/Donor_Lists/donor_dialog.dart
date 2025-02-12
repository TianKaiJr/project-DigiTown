import 'package:flutter/material.dart';
import 'donor_model.dart';

class DonorDialog extends StatefulWidget {
  final Function(Donor) onSave;

  DonorDialog({required this.onSave});

  @override
  _DonorDialogState createState() => _DonorDialogState();
}

class _DonorDialogState extends State<DonorDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? gender;
  String? bloodType;

  void _saveDonor() {
    if (_formKey.currentState!.validate()) {
      Donor newDonor = Donor(
        donorId: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        gender: gender!,
        age: int.parse(ageController.text),
        phoneNumber: phoneController.text,
        bloodType: bloodType!,
        address: "City, State",
        pincode: "123456",
        lastDonationDate: DateTime.now(),
        eligibilityStatus: true,
        registeredDate: DateTime.now(),
      );
      widget.onSave(newDonor);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Donor"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone")),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              value: gender,
              hint: const Text("Select Gender"),
              items: ["Male", "Female", "Other"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => gender = value),
            ),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              value: bloodType,
              hint: const Text("Select Blood Type"),
              items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => bloodType = value),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: _saveDonor, child: const Text("Save"))],
    );
  }
}
