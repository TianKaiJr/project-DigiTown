import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/ZTemporary/constants.dart';
import 'package:super_admin_panel/ZTemporary/controllers/menu_app_controller.dart';
import 'package:super_admin_panel/ZTemporary/responsive.dart';
import 'package:super_admin_panel/ZTemporary/screens/panchayat/screens/contacts_screen.dart';
import 'package:super_admin_panel/ZTempModule/temp.dart';

class PanchayatScreen extends StatefulWidget {
  const PanchayatScreen({super.key});

  @override
  _PanchayatScreenState createState() => _PanchayatScreenState();
}

class _PanchayatScreenState extends State<PanchayatScreen> {
  String selectedOption = '';

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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PanchayatHeader(),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          PanchayatOptionBox(
                            title: "Complaints",
                            icon: Icons.feedback_outlined,
                            onTap: () => setState(() {
                              selectedOption = 'attendance';
                            }),
                          ),
                          PanchayatOptionBox(
                            title: "Contacts",
                            icon: Icons.contacts_outlined,
                            onTap: () => setState(() {
                              selectedOption = 'contacts';
                            }),
                          ),
                          PanchayatOptionBox(
                            title: "News & Events",
                            icon: Icons.newspaper_outlined,
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
                        : _getScreenPanchayat(selectedOption),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to return the correct screen based on the selected option
  Widget _getScreenPanchayat(String option) {
    switch (option) {
      case 'contacts':
        return const ContactScreen();
      case 'appointments':
        return const TempPage();
      case 'calendar':
        return const TempPage();
      default:
        return const Center(
          child: Text(
            'Invalid option selected',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        );
    }
  }
}

class PanchayatOptionBox extends StatefulWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  const PanchayatOptionBox({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  _PanchayatOptionBoxState createState() => _PanchayatOptionBoxState();
}

class _PanchayatOptionBoxState extends State<PanchayatOptionBox> {
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
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign
                      .center, // Ensures text is centered for multiple lines
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PanchayatHeader extends StatelessWidget {
  const PanchayatHeader({
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
            "Panchayat",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
      ],
    );
  }
}
