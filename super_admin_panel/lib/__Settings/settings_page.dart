import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_admin_panel/__Profile/profile_page.dart';
import 'package:super_admin_panel/__Settings/restart.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      prefs.setBool('darkMode', value);
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    RestartWidget.restartApp(context);
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBar(title: "Settings"),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          // Account Settings
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () {}, // Implement password change logic
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
          const Divider(),

          // App Preferences
          SwitchListTile(
            title: const Text("Dark Mode (theme not enabled)"),
            secondary: const Icon(Icons.dark_mode),
            value: _isDarkMode,
            onChanged: _toggleTheme,
          ),
          const Divider(),

          // Security & Privacy
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete Account",
                style: TextStyle(color: Colors.red)),
            onTap: _deleteAccount,
          ),
          const Divider(),

          // Support & About
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help & Support"),
            onTap: () {}, // Implement Help & Support
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text("About App"),
            subtitle: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }
}
