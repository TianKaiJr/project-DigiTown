import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Sample list of appointments
            ListView(
              shrinkWrap: true,
              children: const [
                AppointmentCard(
                  patientName: 'John Doe',
                  appointmentTime: '2024-12-01 10:00 AM',
                  doctor: 'Dr. Smith',
                ),
                AppointmentCard(
                  patientName: 'Jane Smith',
                  appointmentTime: '2024-12-02 02:00 PM',
                  doctor: 'Dr. Brown',
                ),
                AppointmentCard(
                  patientName: 'Alice Johnson',
                  appointmentTime: '2024-12-03 11:30 AM',
                  doctor: 'Dr. Davis',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String patientName;
  final String appointmentTime;
  final String doctor;

  const AppointmentCard({
    super.key,
    required this.patientName,
    required this.appointmentTime,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patientName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Appointment Time: $appointmentTime'),
            const SizedBox(height: 8),
            Text('Doctor: $doctor'),
          ],
        ),
      ),
    );
  }
}
