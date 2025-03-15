import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'doctor_lta_view_model.dart';
import 'doctor_lta_dialog.dart';

class DoctorLTAScreen extends StatelessWidget {
  const DoctorLTAScreen({super.key});

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
                        TableCalendar<bool>(
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: viewModel.focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(viewModel.selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            viewModel.updateSelectedDay(selectedDay);
                            viewModel.updateFocusedDay(focusedDay);
                            viewModel.toggleAvailability(selectedDay);
                          },
                          calendarFormat: viewModel.calendarFormat,
                          onFormatChanged: viewModel.updateCalendarFormat,
                          onPageChanged: viewModel.updateFocusedDay,
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              bool isAvailable =
                                  viewModel.availabilityMap[day] ?? false;
                              return Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color:
                                      isAvailable ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text('${day.day}',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                              );
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: DoctorLTADialog(),
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
