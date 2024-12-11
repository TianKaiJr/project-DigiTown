import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/constants.dart';
import 'package:super_admin_panel/controllers/menu_app_controller.dart';
import 'package:super_admin_panel/responsive.dart';
import 'package:super_admin_panel/screens/hospital/screens/appointment_screen.dart';
import 'package:super_admin_panel/screens/hospital/screens/attendence_screen.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  _HospitalScreenState createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  String selectedOption = ''; // Track selected option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Left side: Option Boxes
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HospitalHeader(),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        OptionBox(
                          title: "Attendance",
                          icon: Icons.event_available,
                          onTap: () => setState(() {
                            selectedOption = 'attendance';
                          }),
                        ),
                        OptionBox(
                          title: "Appointments",
                          icon: Icons.calendar_today,
                          onTap: () => setState(() {
                            selectedOption = 'appointments';
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right side: Preview content based on selected option
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Container(
                  margin: const EdgeInsets.all(16.0), // Space from edges
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: selectedOption.isEmpty
                        ? const Center(
                            child: Text(
                              'Please select an option to view details',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : selectedOption == 'attendance'
                            ? const AttendanceScreen()
                            : const AppointmentsScreen(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OptionBox extends StatefulWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  const OptionBox({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  _OptionBoxState createState() => _OptionBoxState();
}

class _OptionBoxState extends State<OptionBox> {
  bool isHovered = false; // Track hover state

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.blueAccent
                : const Color.fromARGB(255, 61, 161, 255),
            borderRadius: BorderRadius.circular(15),
            boxShadow: isHovered
                ? [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HospitalHeader extends StatelessWidget {
  const HospitalHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Hospital",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
      ],
    );
  }
}
