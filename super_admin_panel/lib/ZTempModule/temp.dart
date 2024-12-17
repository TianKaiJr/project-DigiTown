import 'package:flutter/material.dart';

class TempPage extends StatelessWidget {
  const TempPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temporary Page'),
        centerTitle: true, // Centers the title
        backgroundColor: Colors.blue, // Customize the AppBar color
      ),
      body: const Center(
        child: Text(''), // Empty body
      ),
    );
  }
}
