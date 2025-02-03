import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Section 1'),
            onTap: () {
              Navigator.pop(context);
              // Add your action here
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Section 2'),
            onTap: () {
              Navigator.pop(context);
              // Add your action here
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Section 3'),
            onTap: () {
              Navigator.pop(context);
              // Add your action here
            },
          ),
        ],
      ),
    );
  }
}
