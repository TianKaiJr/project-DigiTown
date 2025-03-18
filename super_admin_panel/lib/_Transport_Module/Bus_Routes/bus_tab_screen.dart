import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';
import 'package:super_admin_panel/_Transport_Module/Bus_Routes/bus_route_mgr.dart';
import 'package:super_admin_panel/_Transport_Module/Bus_Routes/busl_list_screen.dart';

class BusRoutesManager extends StatefulWidget {
  const BusRoutesManager({super.key});

  @override
  _BusRoutesManagerState createState() => _BusRoutesManagerState();
}

class _BusRoutesManagerState extends State<BusRoutesManager>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Bus Routes Manager"),
      body: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.white,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: "Buses"),
                Tab(text: "Routes"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BusListScreen(),
                RouteListScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
