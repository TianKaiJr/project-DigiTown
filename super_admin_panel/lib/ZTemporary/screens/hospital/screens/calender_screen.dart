import 'package:flutter/material.dart';
import 'package:super_admin_panel/ZTemporary/constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Doctor list fetched from Firestore
  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorId;

  // Doctor-specific availability data
  Map<DateTime, bool> _availabilityMap = {};

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  // Fetch doctors from Firestore
  Future<void> _fetchDoctors() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Doctors_Attendence').get();

    setState(() {
      _doctors = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
    });
  }

  // Fetch availability for the selected doctor
  Future<void> _fetchAvailability(String doctorId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Doctors_LTA')
        .doc(doctorId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      Map<DateTime, bool> availability = {};
      data.forEach((key, value) {
        availability[DateTime.parse(key)] = value;
      });

      setState(() {
        _availabilityMap = availability;
      });
    } else {
      setState(() {
        _availabilityMap = {};
      });
    }
  }

  // Toggle availability for a specific day
  void _toggleAvailability(DateTime day) {
    setState(() {
      _availabilityMap[day] = !(_availabilityMap[day] ?? false);
    });
  }

  // Save availability data to Firestore
  Future<void> _saveAvailability() async {
    if (_selectedDoctorId == null) return;

    Map<String, bool> availability = _availabilityMap
        .map((key, value) => MapEntry(key.toIso8601String(), value));

    await FirebaseFirestore.instance
        .collection('Doctors_LTA')
        .doc(_selectedDoctorId)
        .set(availability);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Availability saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40), // Adjust height as needed
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
          child: AppBar(
            title: const Text("Doctor Availability Calendar"),
            centerTitle: true,
            elevation: 5,
            backgroundColor: bgColor, // Custom color
          ),
        ),
      ),
      body: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedDoctorId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.pink,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            hint: const Text('Select a Doctor'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDoctorId = newValue;
              });
              _fetchAvailability(newValue!);
            },
            items: _doctors
                .map((doctor) => DropdownMenuItem<String>(
                      value: doctor['id'],
                      child: Text(doctor['name']),
                    ))
                .toList(),
          ),
          if (_selectedDoctorId != null)
            Expanded(
              child: Column(
                children: [
                  TableCalendar<bool>(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _toggleAvailability(selectedDay);
                      });
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        bool isAvailable = _availabilityMap[day] ?? false;
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Available'),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Unavailable'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveAvailability,
                    child: const Text('Save Availability'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
