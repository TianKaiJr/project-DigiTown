import 'package:flutter/material.dart';
import 'package:main_app/components/list_tiles.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  const MyDrawer({super.key, required this.onProfileTap, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            const DrawerHeader(
                child: Icon(
              Icons.account_circle,
              color: Colors.black,
              size: 104,
            )),
            MyListTile(
                icon: Icons.home,
                text: "Home",
                ontap: () => Navigator.pop(context)),
            MyListTile(icon: Icons.person, text: "Person", ontap: onProfileTap),
            MyListTile(icon: Icons.logout, text: "Logout", ontap: onSignOut),
          ],
        ),
      ),
    );
  }
}
