import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class BookingAppointment extends StatefulWidget {
  final String hospitalId;        // Firestore doc ID for the chosen hospital
  final String hospitalName;      // The hospital's name (if you want to show it)
  final List<String> departments; // List of departments from that hospital

  const BookingAppointment({
    Key? key,
    required this.hospitalId,
    required this.hospitalName,
    required this.departments,
  }) : super(key: key);

  @override
  State<BookingAppointment> createState() => _BookingAppointmentState();
}

class _BookingAppointmentState extends State<BookingAppointment> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Department & Doctor selection
  String? _selectedDepartment;
  List<Map<String, dynamic>> _doctorsList = [];
  String? _selectedDoctorId; // This will now be the *doctor's name*, matching the doc ID in Doctors_LTA

  // Availability
  Map<DateTime, bool> _availability = {};
  DateTime? _selectedDate;
  StreamSubscription<DocumentSnapshot>? _availabilitySubscription;

  @override
  void dispose() {
    _availabilitySubscription?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Build Department dropdown
  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Select Department",
        border: OutlineInputBorder(),
      ),
      value: _selectedDepartment,
      items: widget.departments.map((dept) {
        return DropdownMenuItem<String>(
          value: dept,
          child: Text(dept),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDepartment = value;
          _selectedDoctorId = null;  // reset doctor
          _doctorsList.clear();      // clear any existing doctors
          _selectedDate = null;      // reset date
          _dateController.clear();
        });
        _fetchDoctors();
      },
      validator: (value) => value == null ? "Please select a department" : null,
    );
  }

  /// Build Doctor dropdown
  Widget _buildDoctorDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Select Doctor",
        border: OutlineInputBorder(),
      ),
      value: _selectedDoctorId,
      items: _doctorsList.map((doctor) {
        return DropdownMenuItem<String>(
          value: doctor['id'],           // This is actually the doctor's *name*
          child: Text(doctor['name']),  // Display the doctor's name
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDoctorId = value;  // e.g. "Febin"
          // Reset date/time each time a new doctor is chosen
          _selectedDate = null;
          _dateController.clear();
        });
        _subscribeToAvailability();
      },
      validator: (value) => value == null ? "Please select a doctor" : null,
    );
  }

  /// Fetch doctors for the chosen hospital + department
  Future<void> _fetchDoctors() async {
    if (_selectedDepartment == null) return;

    try {
      // Convert hospitalId into a Firestore DocumentReference
      final hospitalRef = FirebaseFirestore.instance
          .collection('Hospitals')
          .doc(widget.hospitalId);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .where('Hospital', isEqualTo: hospitalRef)
          .where('Department', isEqualTo: _selectedDepartment)
          .get();

      setState(() {
        _doctorsList = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // The doc's *actual* Firestore ID might be something like "waNjGowv..."
          // but we need the doc's *Name* to match the doc ID in "Doctors_LTA".
          final doctorName = data['Name'] ?? 'Unnamed Doctor';

          return {
            'id': doctorName,    // This becomes the doc ID in Doctors_LTA
            'name': doctorName,  // Also display name in the dropdown
          };
        }).toList();
      });
    } catch (error) {
      debugPrint("Error fetching doctors: $error");
    }
  }

  /// Subscribe to real-time updates for the selected doctor's availability
  void _subscribeToAvailability() {
    if (_selectedDoctorId == null) return;

    // Cancel any previous subscription
    _availabilitySubscription?.cancel();

    // Because "Doctors_LTA" doc IDs are the doctor's *name*, we use _selectedDoctorId
    _availabilitySubscription = FirebaseFirestore.instance
        .collection('Doctors_LTA')
        .doc(_selectedDoctorId) // e.g. "Febin"
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        setState(() {
          _availability.clear();

          data?.forEach((key, value) {
            try {
              // If Firestore has something like "2025-03-10T00:00:00.000Z"
              // parse as UTC and normalize
              final dateUtc = DateTime.parse(key).toUtc();
              final normalizedUtc = DateTime.utc(
                dateUtc.year,
                dateUtc.month,
                dateUtc.day,
              );

              _availability[normalizedUtc] = value as bool;
            } catch (e) {
              debugPrint("Error parsing date: $key -> $e");
            }
          });
        });
      }
    });
  }

  /// Open date picker with color-coded availability
  void _selectDate() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: TableCalendar(
            focusedDay: _selectedDate ?? DateTime.now(),
            firstDay: DateTime.now(),
            lastDay: DateTime(2101),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              // Convert to UTC & normalize
              final selectedDayUtc = selectedDay.toUtc();
              final normalizedSelectedDayUtc = DateTime.utc(
                selectedDayUtc.year,
                selectedDayUtc.month,
                selectedDayUtc.day,
              );

              // Only allow selection if available == true or unknown (null).
              if (_availability[normalizedSelectedDayUtc] == false) return;

              setState(() {
                _selectedDate = normalizedSelectedDayUtc;

                // For display, we can show local date as yyyy-MM-dd
                final localDate = _selectedDate!.toLocal();
                _dateController.text = DateFormat('yyyy-MM-dd').format(localDate);
              });
              Navigator.pop(context);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                // Convert each cell's date to UTC & normalize
                final dateUtc = date.toUtc();
                final normalizedUtc = DateTime.utc(
                  dateUtc.year,
                  dateUtc.month,
                  dateUtc.day,
                );

                final bool? available = _availability[normalizedUtc];
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: available == true
                        ? Colors.green   // Available
                        : available == false
                            ? Colors.red // Unavailable
                            : Colors.grey[300], // Unknown
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  /// Open time picker
  void _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  /// Submit the appointment to Firestore
  void _submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('Hospital_Appointments')
            .add({
          'patientName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'address': _addressController.text,
          'hospitalId': widget.hospitalId,
          'hospitalName': widget.hospitalName,
          'department': _selectedDepartment,
          'doctorId': _selectedDoctorId, // e.g. "Febin"
          'date': _dateController.text,
          'time': _timeController.text,
          'reason': _reasonController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment booked successfully!")),
        );

        // Clear form or pop back, etc.
        Navigator.pop(context);
      } catch (e) {
        debugPrint("Error saving appointment: $e");
      }
    }
  }

  /// Helper to build text fields
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? "This field is required" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book a Service at ${widget.hospitalName}")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("Patient Name", _nameController),
                _buildTextField("Phone Number", _phoneController,
                    keyboardType: TextInputType.phone),
                _buildTextField("Address", _addressController),

                // Department dropdown
                _buildDepartmentDropdown(),
                const SizedBox(height: 8),

                // Doctor dropdown
                _buildDoctorDropdown(),
                const SizedBox(height: 8),

                // Date & Time pickers
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Select Date",
                        _dateController,
                        readOnly: true,
                        onTap: _selectDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        "Time",
                        _timeController,
                        readOnly: true,
                        onTap: _selectTime,
                      ),
                    ),
                  ],
                ),
                _buildTextField("Reason for Visit", _reasonController, maxLines: 3),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitAppointment,
                    child: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
