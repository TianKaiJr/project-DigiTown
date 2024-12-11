import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Records',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Sample Table for Attendance
            DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Status')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('2024-12-01')),
                  DataCell(Text('John Doe')),
                  DataCell(Text('Present')),
                ]),
                DataRow(cells: [
                  DataCell(Text('2024-12-02')),
                  DataCell(Text('Jane Smith')),
                  DataCell(Text('Absent')),
                ]),
                DataRow(cells: [
                  DataCell(Text('2024-12-03')),
                  DataCell(Text('Alice Johnson')),
                  DataCell(Text('Present')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
