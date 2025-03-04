import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class BookingAppointment extends StatefulWidget {
  const BookingAppointment({super.key});

  @override
  State<BookingAppointment> createState() => _BookingAppointmentState();
}

class _BookingAppointmentState extends State<BookingAppointment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<String> _doctorsList = [];
  String? _selectedDoctor;
  Map<DateTime, bool> _availability = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  void _fetchDoctors() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Doctors_LTA').get();
      setState(() {
        _doctorsList = querySnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (error) {
      print("🔥 Error fetching doctors: $error");
    }
  }

  void _fetchAvailableDates() async {
    if (_selectedDoctor == null) return;
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('Doctors_LTA').doc(_selectedDoctor).get();
      setState(() {
        _availability = {};
        if (docSnapshot.exists) {
          docSnapshot.data()?.forEach((key, value) {
            DateTime? date;
            try {
              date = DateTime.parse(key);
            } catch (e) {
              print("❌ Invalid date format: $key");
            }
            if (date != null) {
              _availability[date] = value;
            }
          });
        }
      });
    } catch (error) {
      print("🔥 Error fetching availability: $error");
    }
  }

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
              if (_availability[selectedDay] == false) return;
              setState(() {
                _selectedDate = selectedDay;
                _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDay);
              });
              Navigator.pop(context);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                bool? available = _availability[date];
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: available == true ? Colors.green : available == false ? Colors.red : Colors.grey[300],
                  ),
                  child: Center(
                    child: Text('${date.day}', style: const TextStyle(color: Colors.black)),
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

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Hospital_Appointments').add({
          'patientName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'address': _addressController.text,
          'doctor': _selectedDoctor,
          'date': _dateController.text,
          'time': _timeController.text,
          'reason': _reasonController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment booked successfully!")),
        );
      } catch (e) {
        print("🔥 Error saving appointment: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book a Service")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("Patient Name", _nameController),
                _buildTextField("Phone Number", _phoneController, keyboardType: TextInputType.phone),
                _buildTextField("Address", _addressController),
                _buildDoctorDropdown(),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Select Date", _dateController, readOnly: true, onTap: _selectDate)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField("Time", _timeController, readOnly: true, onTap: _selectTime)),
                  ],
                ),
                _buildTextField("Reason for Visit", _reasonController, maxLines: 3),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
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
        validator: (value) => value == null || value.trim().isEmpty ? "This field is required" : null,
      ),
    );
  }

  Widget _buildDoctorDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDoctor ?? (_doctorsList.isNotEmpty ? _doctorsList.first : null),
      decoration: const InputDecoration(
        labelText: "Select Doctor",
        border: OutlineInputBorder(),
      ),
      items: _doctorsList.isNotEmpty
          ? _doctorsList.map((doctor) => DropdownMenuItem(value: doctor, child: Text(doctor))).toList()
          : [const DropdownMenuItem(value: null, child: Text("No doctors available"))],
      onChanged: (value) {
        setState(() {
          _selectedDoctor = value;
          _fetchAvailableDates();
        });
      },
      validator: (value) => value == null ? "Please select a doctor" : null,
    );
  }
}
