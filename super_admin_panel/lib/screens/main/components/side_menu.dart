import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
  });

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
            press: () {},
          ),
          DrawerListTile(
            title: "Panchayat",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Hospital",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Blood Bank",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Transport",
            svgSrc: "assets/icons/menu_store.svg",
            dropdownItems: const ["Autorickshaw", "Bus"],
            press: () {},
          ),
          DrawerListTile(
            title: "Notification",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatefulWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    this.dropdownItems,
    required this.press,
  });

  final String title, svgSrc;
  final VoidCallback press;
  final List<String>? dropdownItems;

  @override
  State<DrawerListTile> createState() => _DrawerListTileState();
}

class _DrawerListTileState extends State<DrawerListTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: widget.dropdownItems != null
              ? () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                }
              : widget.press,
          horizontalTitleGap: 0.0,
          leading: SvgPicture.asset(
            widget.svgSrc,
            colorFilter:
                const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
            height: 16,
          ),
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white54),
          ),
          trailing: widget.dropdownItems != null
              ? Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white54,
                )
              : null,
        ),
        if (isExpanded && widget.dropdownItems != null)
          ...widget.dropdownItems!.map((item) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ListTile(
                title: Text(
                  item,
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  // Handle dropdown item tap
                  debugPrint("$item tapped");
                },
              ),
            );
          }),
      ],
    );
  }
}
