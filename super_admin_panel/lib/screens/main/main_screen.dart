import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/constants.dart';
import 'package:super_admin_panel/controllers/menu_app_controller.dart';
import 'package:super_admin_panel/responsive.dart';
import 'package:super_admin_panel/screens/dashboard/dashboard_screen.dart';
import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Current selected screen
  final ValueNotifier<Widget> _currentScreen =
      ValueNotifier(const DashboardScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(onMenuTap: (Widget screen) {
        _currentScreen.value = screen;
      }),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(
                  onMenuTap: (Widget screen) {
                    _currentScreen.value = screen;
                  },
                ),
              ),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(16.0), // Space from edges
                padding: const EdgeInsets.all(16.0), // Inner padding
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
                child: ValueListenableBuilder<Widget>(
                  valueListenable: _currentScreen,
                  builder: (context, screen, child) {
                    return screen;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
