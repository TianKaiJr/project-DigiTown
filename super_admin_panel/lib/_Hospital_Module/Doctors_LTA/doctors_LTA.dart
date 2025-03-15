import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorLTAViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> doctors = [];
  String? selectedDoctorId;
  DateTime focusedDay = DateTime.now().toUtc();
  DateTime selectedDay = DateTime.now().toUtc();
  CalendarFormat calendarFormat = CalendarFormat.month;
  Map<DateTime, Map<String, dynamic>> availabilityMap = {};
  int maxSlot = 0; // Default max slot value

  DateTime normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  Future<void> fetchDoctors() async {
    final snapshot = await _firestore.collection('Doctors').get();
    doctors = snapshot.docs.map((doc) {
      return {'id': doc.id, 'name': doc['Name'] as String};
    }).toList();
    notifyListeners();
  }

  Future<void> fetchMaxSlot() async {
    final doc = await _firestore
        .collection('ID_Counters')
        .doc('permanent_counters_skeleton')
        .get();
    if (doc.exists) {
      maxSlot = doc.data()?['max_slots'] ?? 0; // Get max_slot from Firestore
    }
  }

  Future<void> fetchAvailability(String doctorId) async {
    selectedDoctorId = doctorId;
    final snapshot =
        await _firestore.collection('Doctors_LTA').doc(doctorId).get();

    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      availabilityMap = data.map((key, value) => MapEntry(
            normalizeDate(DateTime.parse(key)),
            {
              "value": value["value"] as bool,
              "max_slot": value["max_slot"] as int,
              "booked_slot": value["booked_slot"] as int,
            },
          ));
    } else {
      availabilityMap = {};
    }
    notifyListeners();
  }

  void toggleAvailability(DateTime day) async {
    DateTime normalized = normalizeDate(day);

    if (availabilityMap.containsKey(normalized)) {
      availabilityMap[normalized]!["value"] =
          !availabilityMap[normalized]!["value"];
    } else {
      await fetchMaxSlot(); // Ensure maxSlot is updated before adding a new entry
      availabilityMap[normalized] = {
        "value": true,
        "max_slot": maxSlot,
        "booked_slot": 0
      };
    }
    notifyListeners();
  }

  Future<void> saveAvailability(BuildContext context) async {
    if (selectedDoctorId == null) return;

    Map<String, dynamic> saveData = availabilityMap
        .map((key, value) => MapEntry(key.toIso8601String(), value));

    await _firestore
        .collection('Doctors_LTA')
        .doc(selectedDoctorId!)
        .set(saveData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Availability saved successfully!')),
    );
  }

  void updateCalendarFormat(CalendarFormat format) {
    calendarFormat = format;
    notifyListeners();
  }

  void updateFocusedDay(DateTime day) {
    focusedDay = day;
    notifyListeners();
  }
}

class DoctorLTAScreen2 extends StatelessWidget {
  const DoctorLTAScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DoctorLTAViewModel()..fetchDoctors(),
      child: Consumer<DoctorLTAViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: const CustomAppBar(title: "Doctor Availability Calendar"),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: viewModel.selectedDoctorId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    hint: const Text('Select a Doctor'),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        viewModel.fetchAvailability(newValue);
                      }
                    },
                    items: viewModel.doctors.map((doctor) {
                      return DropdownMenuItem<String>(
                        value: doctor['id'],
                        child: Text(doctor['name'] ?? 'Unknown'),
                      );
                    }).toList(),
                  ),
                ),
                if (viewModel.selectedDoctorId != null)
                  Expanded(
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: viewModel.focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(viewModel.selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            viewModel.toggleAvailability(selectedDay);
                          },
                          calendarFormat: viewModel.calendarFormat,
                          onFormatChanged: (format) =>
                              viewModel.updateCalendarFormat(format),
                          onPageChanged: (focusedDay) =>
                              viewModel.updateFocusedDay(focusedDay),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              DateTime normalizedDay =
                                  DateTime.utc(day.year, day.month, day.day);
                              bool isAvailable =
                                  viewModel.availabilityMap[normalizedDay]
                                          ?["value"] ??
                                      false;
                              return Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color:
                                      isAvailable ? Colors.green : Colors.red,
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
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: CalendarAvailabilityLegend(),
                        ),
                        ElevatedButton(
                          onPressed: () => viewModel.saveAvailability(context),
                          child: const Text('Save Availability'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CalendarAvailabilityLegend extends StatelessWidget {
  const CalendarAvailabilityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LegendItem(color: Colors.green, label: 'Available'),
        SizedBox(width: 20),
        LegendItem(color: Colors.red, label: 'Unavailable'),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
