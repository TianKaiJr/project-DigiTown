import 'package:flutter/material.dart';

class BusServicePage extends StatefulWidget {
  const BusServicePage({super.key});

  @override
  _BusServicePageState createState() => _BusServicePageState();
}

class _BusServicePageState extends State<BusServicePage> {
  final List<Route> routes = [
    Route("1", {"Malayattor": 0, "Neeleswaram": 15, "Kalady": 20, "Angamaly": 30}),
    Route("2", {"Angamaly": 0, "Kalady": 10, "Neeleswaram": 15, "Malayattor": 30}),
    Route("3", {"Perumbavoor": 0, "Vallam": 10, "Okkal": 15, "Kalady": 20, "Angamaly": 30}),
    Route("4", {"Angamaly": 0, "Kalady": 10, "Okkal": 15, "Vallam": 20, "Perumbavoor": 30}),
  ];

  final List<Bus> buses = [
    Bus("Friends", "3", [10.00, 11.15, 12.00]),
    Bus("Geo Travels", "4", [9.00, 10.45, 11.30, 15.00]),
    Bus("Metro Express", "1", [8.30, 9.45, 12.15, 14.00]),
    Bus("City Link", "2", [7.00, 9.30, 11.45, 13.15]),
    Bus("Fast Wheels", "3", [6.45, 8.50, 10.40, 13.30]),
  ];

  String start = "";
  String end = "";
  double searchTime = 0.0;
  List<Map<String, dynamic>> result = [];

  void searchBuses() {
    result.clear();
    List<Route> selectedRoutes = [];

    String normalizedStart = start.toLowerCase();
    String normalizedEnd = end.toLowerCase();

    for (var route in routes) {
      Map<String, int> normalizedDestinations = {
        for (var key in route.destinations.keys) key.toLowerCase(): route.destinations[key]!
      };

      if (normalizedDestinations.containsKey(normalizedStart) && normalizedDestinations.containsKey(normalizedEnd)) {
        int timeDiff = normalizedDestinations[normalizedEnd]! - normalizedDestinations[normalizedStart]!;
        if (timeDiff > 0) {
          selectedRoutes.add(Route(route.routeName, normalizedDestinations));
        }
      }
    }

    for (var selectedRoute in selectedRoutes) {
      int startTime = selectedRoute.destinations[normalizedStart]!;
      for (var bus in buses) {
        if (bus.route == selectedRoute.routeName) {
          for (var time in bus.startTimes) {
            int baseHours = time.toInt();
            int baseMinutes = ((time - baseHours) * 100).round();

            int arrivalMinutes = baseMinutes + startTime;
            int arrivalHours = baseHours + (arrivalMinutes ~/ 60);
            arrivalMinutes %= 60;

            String arrivalTime = "${arrivalHours.toString().padLeft(2, '0')}:${arrivalMinutes.toString().padLeft(2, '0')}";

            if ((arrivalHours * 60 + arrivalMinutes) >= (searchTime.toInt() * 60 + ((searchTime - searchTime.toInt()) * 100).toInt())) {
              result.add({"bus": bus.name, "arrival_time": arrivalTime});
            }
          }
        }
      }
    }
    result.sort((a, b) => a["arrival_time"].compareTo(b["arrival_time"]));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Service'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Welcome to Bus Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: "Starting Point",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => start = val,
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: const InputDecoration(
                labelText: "Ending Point",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => end = val,
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: const InputDecoration(
                labelText: "Time (HH.MM)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) => searchTime = double.tryParse(val) ?? 0.0,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: searchBuses,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Search Buses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            result.isEmpty
                ? const Center(
                    child: Text(
                      "No buses available",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.directions_bus, color: Colors.blue),
                            title: Text(
                              "Bus: ${result[index]["bus"]}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              "Arrival Time: ${result[index]["arrival_time"]}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
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

class Route {
  String routeName;
  Map<String, int> destinations; // Destination -> Time taken

  Route(this.routeName, this.destinations);
}

class Bus {
  String name;
  String route;
  List<double> startTimes; // Start times in HH.MM format

  Bus(this.name, this.route, this.startTimes);
}
