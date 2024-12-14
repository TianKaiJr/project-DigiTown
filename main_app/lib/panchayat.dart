import 'package:flutter/material.dart';

class PanchayatPage extends StatelessWidget {
  const PanchayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panchayat Page")),
      body: const Center(
        child: Text("Welcome to the Panchayat Page"),
      ),
    );
  }
}
