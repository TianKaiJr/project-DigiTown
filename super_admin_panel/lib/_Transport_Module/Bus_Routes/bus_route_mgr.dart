import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// --------------------- ROUTES SCREEN ---------------------

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  _RouteListScreenState createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _deleteRoute(DocumentSnapshot doc) {
    doc.reference.delete();
  }

  // 🛠️ Show Alert Dialog for adding a new route
  void _showAddRouteDialog() {
    List<TextEditingController> nameControllers = [];
    List<TextEditingController> distanceControllers = [];

    // Function to add new text fields dynamically
    void addDestinationField() {
      setState(() {
        nameControllers.add(TextEditingController());
        distanceControllers.add(TextEditingController());
      });
    }

    // Initialize with two fields
    addDestinationField();
    addDestinationField();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add New Route"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < nameControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameControllers[i],
                              decoration: const InputDecoration(
                                labelText: "Destination Name",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: distanceControllers[i],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "MIN",
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          addDestinationField();
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add More"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<Map<String, dynamic>> destinations = [];
                    for (int i = 0; i < nameControllers.length; i++) {
                      if (nameControllers[i].text.isNotEmpty &&
                          distanceControllers[i].text.isNotEmpty) {
                        destinations.add({
                          "name": nameControllers[i].text,
                          "time":
                              int.tryParse(distanceControllers[i].text) ?? 0,
                        });
                      }
                    }

                    if (destinations.isNotEmpty) {
                      // 🔹 Generate routeName automatically
                      String routeName =
                          destinations.map((d) => d["name"]).join("-");

                      await _firestore.collection('routes').add({
                        "routeName": routeName,
                        "destinations": destinations,
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Bus Routes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('routes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var routes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              var route = routes[index];

              // ✅ Check if 'destinations' exists and is a list
              List<dynamic> destinationsList = [];
              if (route.data() != null && route['destinations'] is List) {
                destinationsList = route['destinations'];
              } else if (route['destinations'] is Map) {
                destinationsList =
                    (route['destinations'] as Map).values.toList();
              }

              return ListTile(
                title: Text(route['routeName'] ?? 'Unknown Route'),
                subtitle: Text(
                  destinationsList
                      .whereType<Map<String, dynamic>>()
                      .map((d) =>
                          '${d['name'] ?? 'Unknown'} (${d['time'] ?? 0} min)')
                      .join(', '),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteRoute(route),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRouteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
