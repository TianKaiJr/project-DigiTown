import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  _BusListScreenState createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showBusDialog({DocumentSnapshot? doc}) {
    TextEditingController nameController =
        TextEditingController(text: doc?['name'] ?? '');

    List<TextEditingController> startTimesControllers = [];

    String? selectedRoute = doc?['route'];

    if (doc != null && doc['startTimes'] is List) {
      for (var time in doc['startTimes']) {
        startTimesControllers.add(TextEditingController(text: time.toString()));
      }
    } else {
      startTimesControllers.add(TextEditingController());
    }

    void addStartTimeField() {
      setState(() {
        startTimesControllers.add(TextEditingController());
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(doc == null ? 'Add Bus' : 'Edit Bus'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Bus Name'),
                    ),
                    const SizedBox(height: 10),
                    const Text("Start Times"),
                    for (int i = 0; i < startTimesControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startTimesControllers[i],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Enter Start Time",
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          addStartTimeField();
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add More"),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('routes').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        var routes = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: selectedRoute,
                          onChanged: (value) {
                            setState(() {
                              selectedRoute = value;
                            });
                          },
                          items: routes.map((route) {
                            return DropdownMenuItem(
                              value: route.reference.path,
                              child: Text(route['routeName']),
                            );
                          }).toList(),
                          decoration:
                              const InputDecoration(labelText: 'Select Route'),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || selectedRoute == null) {
                      return;
                    }

                    List<double> startTimes = startTimesControllers
                        .map((controller) =>
                            double.tryParse(controller.text.trim()) ?? 0)
                        .where((time) => time > 0)
                        .toList();

                    if (doc == null) {
                      await _firestore.collection('buses').add({
                        'name': nameController.text,
                        'startTimes': startTimes,
                        'route': selectedRoute,
                      });
                    } else {
                      await doc.reference.update({
                        'name': nameController.text,
                        'startTimes': startTimes,
                        'route': selectedRoute,
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: Text(doc == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteBus(DocumentSnapshot doc) {
    doc.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('buses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var buses = snapshot.data!.docs;
          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              var bus = buses[index];

              return ListTile(
                title: Text(bus['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Start Times: ${(bus['startTimes'] as List).join(', ')}'),
                    FutureBuilder<DocumentSnapshot>(
                      future: _firestore.doc(bus['route']).get(),
                      builder: (context, routeSnapshot) {
                        if (!routeSnapshot.hasData) {
                          return const Text('Route: Loading...');
                        }
                        return Text(
                            'Route: ${routeSnapshot.data!['routeName']}');
                      },
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBus(bus),
                ),
                onTap: () => _showBusDialog(doc: bus),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showBusDialog(),
      ),
    );
  }
}
