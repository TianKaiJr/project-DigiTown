import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_admin_panel/screens/dashboard/dashboard_screen.dart';
import 'package:super_admin_panel/screens/hospital/hospital_screen.dart';

class SideMenu extends StatelessWidget {
  final ValueChanged<Widget> onMenuTap;

  const SideMenu({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () => onMenuTap(const DashboardScreen()),
          ),
          DrawerListTile(
            title: "Hospital",
            svgSrc: "assets/icons/menu_task.svg",
            press: () => onMenuTap(const HospitalScreen()),
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
  });

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
