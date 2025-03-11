import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Transport_Module/Bus_Routes/bus_route_mgr.dart';
import 'package:super_admin_panel/_Transport_Module/Bus_Routes/busl_list_screen.dart';

class BusRoutesManager extends StatelessWidget {
  const BusRoutesManager({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bus Routes Manager'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Buses'),
              Tab(text: 'Routes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BusListScreen(),
            RouteListScreen(),
          ],
        ),
      ),
    );
  }
}
