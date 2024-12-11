import 'package:flutter/material.dart';

class PalliativeCarePage extends StatefulWidget {
  const PalliativeCarePage({super.key});

  @override
  State<PalliativeCarePage> createState() => _PalliativeCarePageState();
}

class _PalliativeCarePageState extends State<PalliativeCarePage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // List of services
  final List<String> _services = [
    'Skilled Nurse',
    'Ambulance',
    'Air Mattress',
    'Mosquito Kit',
    'Doctor Visit',
    'Medical Equipments',
  ];

  // Select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Select time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Submit form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking Submitted Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // AppBar with Transparent Background
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Book a Service',
                    style: TextStyle(color: Colors.teal),
                  ),
                  centerTitle: true,
                  iconTheme: IconThemeData(color: Colors.teal),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Patient Name
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Patient Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the patient name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Address
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the address';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Pincode
                            TextFormField(
                              controller: _pincodeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Pincode',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the pincode';
                                }
                                if (value.length != 6) {
                                  return 'Pincode must be 6 digits';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Service Selection
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'What service do you opt?',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedService,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedService = newValue;
                                });
                              },
                              items: _services.map((service) {
                                return DropdownMenuItem(
                                  value: service,
                                  child: Text(
                                    service,
                                    style: TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a service';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Date Selection
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _selectDate(context),
                                    child: Text(
                                      _selectedDate == null
                                          ? 'Select Date'
                                          : 'Date: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Time Selection
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _selectTime(context),
                                    child: Text(
                                      _selectedTime == null
                                          ? 'Select Time'
                                          : 'Time: ${_selectedTime!.format(context)}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Submit Button with Gradient
                            GestureDetector(
                              onTap: _submitForm,
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFA8BFF),
                                      Color(0xFF2BD2FF),
                                      Color(0xFF2BFF88),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
