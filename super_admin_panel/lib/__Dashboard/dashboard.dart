import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final List<Module> modules = [
    Module("Donors", Icons.bloodtype, 4),
    Module("Requests", Icons.request_page, 3),
    Module("History", Icons.history, 2),
    Module("Attendance", Icons.calendar_today, 5),
    Module("Taxi Service", Icons.local_taxi, 4),
  ];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Adjust based on available space
            childAspectRatio: 1.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            return DashboardTile(module: modules[index]);
          },
        ),
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final Module module;

  const DashboardTile({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModuleDetailScreen(module: module),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(module.icon, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              module.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text("${module.options} Options"),
          ],
        ),
      ),
    );
  }
}

class ModuleDetailScreen extends StatelessWidget {
  final Module module;

  const ModuleDetailScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(module.name)),
      body: Center(
        child: Text(
          "Details for ${module.name} with ${module.options} options",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class Module {
  final String name;
  final IconData icon;
  final int options;

  Module(this.name, this.icon, this.options);
}
