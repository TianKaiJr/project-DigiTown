import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../view_models/calendar_view_model.dart';
import '../widgets/calendar_availability_legend.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalendarViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Availability Calendar'),
      ),
      body: Column(
        children: [
          DropdownButtonFormField<String>(
            value: viewModel.selectedDoctorId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            hint: const Text('Select a Doctor'),
            onChanged: (String? newValue) {
              if (newValue != null) viewModel.selectDoctor(newValue);
            },
            items: viewModel.doctors.map((doctor) {
              return DropdownMenuItem(
                value: doctor.id,
                child: Text(doctor.name),
              );
            }).toList(),
          ),
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.selectedDoctorId != null)
            Expanded(
              child: Column(
                children: [
                  TableCalendar<bool>(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: DateTime.now(),
                    selectedDayPredicate: (day) =>
                        viewModel.availabilityMap[day] ?? false,
                    onDaySelected: (selectedDay, focusedDay) {
                      viewModel.toggleAvailability(selectedDay);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final isAvailable =
                            viewModel.availabilityMap[day] ?? false;
                        return Container(
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
                  const CalendarAvailabilityLegend(),
                  ElevatedButton(
                    onPressed: viewModel.saveAvailability,
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
