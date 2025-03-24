import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'dart:math'; // For min()
import 'NoInternetComponent/Utils/network_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Search',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BusServicePage(),
    );
  }
}

class BusServicePage extends StatefulWidget {
  const BusServicePage({super.key});

  @override
  _BusSearchPageState createState() => _BusSearchPageState();
}

class _BusSearchPageState extends State<BusServicePage> {
  // Controllers for start and end locations
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  bool isLoading = false;       // Are we fetching data?
  bool hasSearched = false;    // Has user performed a search yet?

  bool _isToday = true;        // "Today" or "Tomorrow"
  bool _useCustomDate = false; // Whether user picked a custom date

  late DateTime _selectedDate; // For date display
  String _sortOption = 'Earliest First'; // or 'Latest First'

  // Final matching buses
  List<Map<String, dynamic>> result = [];

  // How many buses we currently show
  int _displayCount = 0;

  // All possible place names (for autocomplete suggestions)
  List<String> _allPlaces = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Default to "Today"
    _loadAllPlaces();               // Load known place names from Firestore
  }

  /// Fetch all unique destination names from "routes" collection
  Future<void> _loadAllPlaces() async {
    try {
      final routesSnap =
          await FirebaseFirestore.instance.collection('routes').get();

      final Set<String> places = {};
      for (var doc in routesSnap.docs) {
        final data = doc.data();
        if (data.containsKey('destinations')) {
          final List<dynamic> destinations = data['destinations'];
          for (var dest in destinations) {
            if (dest is Map) {
              final name = dest['name'] as String;
              places.add(name);
            }
          }
        }
      }
      setState(() {
        _allPlaces = places.toList();
      });
    } catch (e) {
      debugPrint("Error loading places: $e");
    }
  }

  /// Allows user to pick a custom date from the calendar
  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        // user picked a custom date => not "today" logic
        _useCustomDate = true;
        _isToday = false;
        _selectedDate = picked;
      });
    }
  }

  /// Switch between Today and Tomorrow
  void _chooseTodayOrTomorrow(bool today) {
    setState(() {
      _useCustomDate = false; // turning off custom date if they pick today/tomorrow
      _isToday = today;
      final now = DateTime.now();
      if (_isToday) {
        // "Today"
        _selectedDate = now;
      } else {
        // "Tomorrow"
        _selectedDate = DateTime(now.year, now.month, now.day + 1);
      }
    });
  }

  /// Swap the text in the two TextFields
  void _swapStartEnd() {
    setState(() {
      final temp = startController.text;
      startController.text = endController.text;
      endController.text = temp;
    });
  }

  /// Format date like "12 MAR WED"
  String _formatDate(DateTime date) {
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    final day = date.day;
    final month = months[date.month - 1];
    final weekday = weekdays[date.weekday - 1];

    return '$day $month $weekday';
  }

  /// Sort the 'result' list in memory according to _sortOption
  void _sortResultsInMemory() {
    // Sort ascending by arrival_time first
    result.sort((a, b) {
      final timeA = a['arrival_time'].split(':');
      final timeB = b['arrival_time'].split(':');
      final totalMinutesA = int.parse(timeA[0]) * 60 + int.parse(timeA[1]);
      final totalMinutesB = int.parse(timeB[0]) * 60 + int.parse(timeB[1]);
      return totalMinutesA.compareTo(totalMinutesB);
    });

    // If user chose "Latest First," reverse
    if (_sortOption == 'Latest First') {
      result = result.reversed.toList();
    }
  }

  /// Main logic: Query Firestore, collect ALL matching buses
  /// If "Today," only show after current time
  /// If "Tomorrow," show all
  /// If custom date, show all times
  Future<void> searchBuses() async {
    try {
      final String start = startController.text.trim();
      final String end = endController.text.trim();

      // Lowercase for case-insensitive matching
      final String startLower = start.toLowerCase();
      final String endLower = end.toLowerCase();

      setState(() {
        isLoading = true;
        hasSearched = true;
        result.clear();
      });

      final QuerySnapshot busSnapshot =
          await FirebaseFirestore.instance.collection('buses').get();

      List<Map<String, dynamic>> foundBuses = [];

      // For time comparison, get "now" in minutes from midnight
      final now = DateTime.now();
      final int currentMinutes = now.hour * 60 + now.minute;

      // For each bus doc
      for (var busDoc in busSnapshot.docs) {
        final busData = busDoc.data() as Map<String, dynamic>;

        // route is a string, e.g. "routes/xxxxxx"
        final String routePath = busData['route'];
        final DocumentReference routeRef =
            FirebaseFirestore.instance.doc(routePath);

        // get the route doc
        final DocumentSnapshot routeDoc = await routeRef.get();
        if (!routeDoc.exists) continue;

        final routeData = routeDoc.data() as Map<String, dynamic>;
        final List<dynamic> destinations = routeData['destinations'];

        // find start & end ignoring case
        final startItem = destinations.firstWhere(
          (item) => (item['name'] as String).toLowerCase() == startLower,
          orElse: () => null,
        );
        final endItem = destinations.firstWhere(
          (item) => (item['name'] as String).toLowerCase() == endLower,
          orElse: () => null,
        );

        if (startItem == null || endItem == null) {
          continue; // skip if not found
        }

        final int startMinutes = startItem['time'];
        final int endMinutes = endItem['time'];

        // must travel from start -> end in correct order
        if (startMinutes < endMinutes) {
          // check all "startTimes"
          for (var time in busData['startTimes']) {
            double startTime = double.tryParse(time.toString()) ?? 0.0;
            int startHour = startTime.floor();
            int startMinute = ((startTime - startHour) * 100).round();

            // total offset from midnight
            int totalMinutes = (startHour * 60) + startMinute + startMinutes;
            int arrivalHours = totalMinutes ~/ 60;
            int arrivalMinutes = totalMinutes % 60;

            // Decide if we show this bus based on "Today", "Tomorrow", or custom date
            bool passesTimeCheck = true;
            if (_useCustomDate) {
              // If user chose a custom date, we skip the "past time" filter
              // (We assume your Firestore data doesn't store a bus date, so we can't truly compare dates.)
              passesTimeCheck = true;
            } else if (_isToday) {
              // "Today" => only show buses that depart after current time
              if (totalMinutes < currentMinutes) {
                passesTimeCheck = false;
              }
            } else {
              // "Tomorrow" => show all
              passesTimeCheck = true;
            }

            if (passesTimeCheck) {
              foundBuses.add({
                "bus": busData['name'],
                "arrival_time":
                    "${arrivalHours.toString().padLeft(2, '0')}:${arrivalMinutes.toString().padLeft(2, '0')}",
              });
            }
          }
        }
      }

      // assign to result, then sort
      result = foundBuses;
      _sortResultsInMemory();

      // show first 10
      _displayCount = min(10, result.length);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Show 15 more results
  void _showMore() {
    setState(() {
      _displayCount += 15;
      if (_displayCount > result.length) {
        _displayCount = result.length;
      }
    });
  }

  /// Autocomplete for the "Start" field
  Widget _buildStartAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) {
          return const Iterable<String>.empty();
        }
        // Return all places that contain the query (case-insensitive)
        return _allPlaces.where(
          (place) => place.toLowerCase().contains(query),
        );
      },
      onSelected: (String selection) {
        startController.text = selection;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // Keep the Autocomplete's controller in sync with ours
        textEditingController.text = startController.text;
        return Row(
          children: [
            const Icon(Icons.directions_bus),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: "Start"),
                onChanged: (val) {
                  startController.text = val;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Autocomplete for the "End" field
  Widget _buildEndAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) {
          return const Iterable<String>.empty();
        }
        // Return all places that contain the query (case-insensitive)
        return _allPlaces.where(
          (place) => place.toLowerCase().contains(query),
        );
      },
      onSelected: (String selection) {
        endController.text = selection;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // Keep the Autocomplete's controller in sync with ours
        textEditingController.text = endController.text;
        return Row(
          children: [
            const Icon(Icons.directions_bus),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: "End"),
                onChanged: (val) {
                  endController.text = val;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// The main build method
  @override
  Widget build(BuildContext context) {
    final dateString = _formatDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Search"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Start/End with autocomplete + swap icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildStartAutocomplete(),
                            const SizedBox(height: 16),
                            _buildEndAutocomplete(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Swap button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.swap_vert),
                          onPressed: _swapStartEnd,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // The date row: tap the icon => pick a custom date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _pickDate, // pick a custom date
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined),
                            const SizedBox(width: 8),
                            Text(
                              dateString,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // "Today" / "Tomorrow" toggles
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              NetworkUtils.checkAndProceed(context, () {
                                 _chooseTodayOrTomorrow(true);
                              });
                            },
                            child: const Text("Today"),
                          ),

                          TextButton(
                            onPressed: () {
                              NetworkUtils.checkAndProceed(context, () {
                                _chooseTodayOrTomorrow(false);
                              });
                            },
                            child: const Text("Tomorrow"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sort Option
                  Row(
                    children: [
                      const Text(
                        "Sort by:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _sortOption,
                        items: const [
                          DropdownMenuItem(
                            value: 'Earliest First',
                            child: Text("Earliest First"),
                          ),
                          DropdownMenuItem(
                            value: 'Latest First',
                            child: Text("Latest First"),
                          ),
                        ],
                        onChanged: (value) {
                          NetworkUtils.checkAndProceed(context, () {
                            setState(() {
                              _sortOption = value!;
                              _sortResultsInMemory();
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        NetworkUtils.checkAndProceed(context, searchBuses);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                     child: const Text(
                      "SEARCH BUSES",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  ),
                  const SizedBox(height: 16),

                  // Results
                  Builder(
                    builder: (context) {
                      // 1) If user hasn't searched yet, show nothing
                      if (!hasSearched) {
                        return const SizedBox();
                      }
                      // 2) If we're still loading, don't show "No buses found" yet
                      if (isLoading) {
                        return const SizedBox();
                      }
                      // 3) If we've finished loading but found no buses
                      if (result.isEmpty) {
                        return Column(
                          children: [
                            const Text(
                              "No buses found. Try searching!",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: Lottie.asset(
                                'assets/lottie/no_data.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        );
                      }

                      // 4) Otherwise, show the subset of results
                      final displayed = result.take(_displayCount).toList();
                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayed.length,
                            itemBuilder: (context, index) {
                              final bus = displayed[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.directions_bus),
                                  title: Text("Bus: ${bus['bus']}"),
                                  subtitle: Text(
                                    "Arrival Time: ${bus['arrival_time']}",
                                  ),
                                ),
                              );
                            },
                          ),
                          // "Show More" if there are more buses to display
                          if (_displayCount < result.length)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ElevatedButton(
                                onPressed: _showMore,
                                child: const Text("Show More"),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay with bus animation
          if (isLoading)
            Container(
              color: Colors.white54,
              child: Center(
                // Lottie bus animation (make sure you have bus.json in assets)
                child: Lottie.asset(
                  'assets/lottie/bus.json',
                  width: 150,
                  height: 150,
                  repeat: true,
                ),
                // or fallback: CircularProgressIndicator()
              ),
            ),
        ],
      ),
    );
  }
}
