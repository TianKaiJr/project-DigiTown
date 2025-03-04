import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingAppoinment extends StatefulWidget {
  const BookingAppoinment({super.key});

  @override
  State<BookingAppoinment> createState() => _BookingAppoinmentState();
}

class _BookingAppoinmentState extends State<BookingAppoinment> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  List<String> _doctorsList = [];
  String? _selectedDoctor;
  Map<DateTime, bool> _availability = {}; // Stores available dates

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  void _fetchDoctors() async {
    FirebaseFirestore.instance
        .collection('Doctors_LTA')
        .get()
        .then((querySnapshot) {
      setState(() {
        _doctorsList = querySnapshot.docs.map((doc) => doc.id).toList();
      });
    }).catchError((error) {
      print("Error fetching doctors: $error");
    });
  }

  void _fetchAvailableDates() async {
    if (_selectedDoctor == null) return;

    FirebaseFirestore.instance
        .collection('Doctors_LTA')
        .doc(_selectedDoctor)
        .collection('Availability')
        .get()
        .then((querySnapshot) {
      setState(() {
        _availability = {
          for (var doc in querySnapshot.docs)
            DateTime.parse(doc.id): doc['available'] == true,
        };
      });
    }).catchError((error) {
      print("Error fetching availability: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book a Service")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Fill Your Details to Book",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField("Patient Name", _nameController),
                      const SizedBox(height: 10),
                      _buildTextField("Phone Number", _phoneController,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 10),
                      _buildTextField("Address", _addressController),
                      const SizedBox(height: 10),
                      _buildDoctorDropdown(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: _buildDatePickerField(
                                  context, "Select Date", _dateController)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildTimePickerField(
                                  context, "Select Time", _timeController)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField("Reason for Visit", _reasonController,
                          maxLines: 3),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Form submitted successfully!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Select Doctor",
        border: OutlineInputBorder(),
      ),
      items: _doctorsList.map((doctor) {
        return DropdownMenuItem(value: doctor, child: Text(doctor));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDoctor = value;
          _fetchAvailableDates();
        });
      },
      validator: (value) => value == null ? "Please select a doctor" : null,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "This field is required";
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField(
      BuildContext context, String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true, // Prevents manual typing
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      onTap: () async {
        FocusScope.of(context)
            .requestFocus(FocusNode()); // Prevents keyboard from opening
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          setState(() {
            controller.text =
                "${pickedDate.toLocal()}".split(' ')[0]; // Formats date
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select a date";
        }
        return null;
      },
    );
  }

  Widget _buildTimePickerField(
      BuildContext context, String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          controller.text = pickedTime.format(context);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select a time";
        }
        return null;
      },
    );
  }
}
