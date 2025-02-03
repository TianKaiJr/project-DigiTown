import 'package:flutter/material.dart';
import 'package:taxi_app/Screens/Main/components/sidebar.dart';
import 'package:taxi_app/Screens/Main/components/toggle.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      drawer: SideBar(),
      body: Center(
        child: ToggleButton(),
      ),
    );
  }
}
