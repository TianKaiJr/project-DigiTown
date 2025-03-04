import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BusServicePage extends StatefulWidget {
  const BusServicePage({super.key});

  @override
  _BusSearchPageState createState() => _BusSearchPageState();
}

class _BusSearchPageState extends State<BusServicePage> {
  String start = "";
  String end = "";
  int searchHour = 0;
  int searchMinute = 0;
  List<Map<String, dynamic>> result = [];

  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default time to current system time
    DateTime now = DateTime.now();
    searchHour = now.hour;
    searchMinute = now.minute;
    timeController.text = "${searchHour.toString().padLeft(2, '0')}.${searchMinute.toString().padLeft(2, '0')}";
  }

  Future<void> searchBuses() async {
    try {
      String start = startController.text.trim();
      String end = endController.text.trim();
      String timeInput = timeController.text.trim();

      // Validate time input format (HH.MM)
      if (!timeInput.contains('.')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter time in HH.MM format (e.g., 10.30)")),
        );
        return;
      }

      // Parse time input
      List<String> timeParts = timeInput.split('.');
      searchHour = int.tryParse(timeParts[0]) ?? 0;
      searchMinute = int.tryParse(timeParts[1]) ?? 0;

      QuerySnapshot busSnapshot = await FirebaseFirestore.instance.collection('buses').get();
      List<Map<String, dynamic>> foundBuses = [];

      for (var busDoc in busSnapshot.docs) {
        var busData = busDoc.data() as Map<String, dynamic>;
        DocumentReference routeRef = busData['route'];
        DocumentSnapshot routeDoc = await routeRef.get();

        if (routeDoc.exists) {
          var routeData = routeDoc.data() as Map<String, dynamic>;
          Map<String, dynamic> destinations = Map<String, dynamic>.from(routeData['destinations']);

          if (destinations.containsKey(start) && destinations.containsKey(end)) {
            int startMinutes = int.tryParse(destinations[start].toString()) ?? 0;
            int endMinutes = int.tryParse(destinations[end].toString()) ?? 0;

            if (startMinutes < endMinutes) {
              for (var time in busData['startTimes']) {
                double startTime = double.tryParse(time.toString()) ?? 0.0;
                int startHour = startTime.floor(); // Extract hour
                int startMinute = ((startTime - startHour) * 100).round(); // Extract minutes

                // Convert to total minutes from midnight
                int totalMinutes = (startHour * 60) + startMinute + startMinutes;
                int arrivalHours = totalMinutes ~/ 60;
                int arrivalMinutes = totalMinutes % 60;

                // Compare user time and bus arrival time
                if (arrivalHours > searchHour || (arrivalHours == searchHour && arrivalMinutes >= searchMinute)) {
                  foundBuses.add({
                    "bus": busData['name'],
                    "arrival_time": "${arrivalHours.toString().padLeft(2, '0')}:${arrivalMinutes.toString().padLeft(2, '0')}"
                  });
                }
              }
            }
          }
        }
      }

      // Sort buses by arrival time
      foundBuses.sort((a, b) {
        List<String> timeA = a['arrival_time'].split(':');
        List<String> timeB = b['arrival_time'].split(':');
        int totalMinutesA = int.parse(timeA[0]) * 60 + int.parse(timeA[1]);
        int totalMinutesB = int.parse(timeB[0]) * 60 + int.parse(timeB[1]);
        return totalMinutesA.compareTo(totalMinutesB);
      });

      setState(() {
        result = foundBuses;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: startController,
              decoration: const InputDecoration(labelText: "Enter Start Point"),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(labelText: "Enter End Point"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Enter Time (HH.MM format)"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () {
                    DateTime now = DateTime.now();
                    setState(() {
                      searchHour = now.hour;
                      searchMinute = now.minute;
                      timeController.text = "${searchHour.toString().padLeft(2, '0')}.${searchMinute.toString().padLeft(2, '0')}";
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: searchBuses,
              child: const Text("Search Buses"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: result.length,
                itemBuilder: (context, index) {
                  var bus = result[index];
                  return ListTile(
                    leading: const Icon(Icons.directions_bus), // Bus icon
                    title: Text("Bus: ${bus['bus']}"),
                    trailing: Text("Arrival Time: ${bus['arrival_time']}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}