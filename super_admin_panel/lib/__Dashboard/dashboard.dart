import 'package:flutter/material.dart';

/// Main dashboard page
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent AppBar for a sleek look
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 16),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F6FC8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Generate Report"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ---- Top Row: Stat Cards ----
            Row(
              children: [
                _buildStatCard(
                  title: "Net Sales",
                  value: "2,500",
                  startColor: const Color(0xFF6F6FC8),
                  endColor: const Color(0xFF9F9FD8),
                ),
                _buildStatCard(
                  title: "Tickets Sold",
                  value: "2/40",
                  startColor: const Color(0xFFFD618E),
                  endColor: const Color(0xFFFF9A9E),
                ),
                _buildStatCard(
                  title: "Add-ons Sold",
                  value: "0/40",
                  startColor: const Color(0xFFFFB157),
                  endColor: const Color(0xFFFFD17F),
                ),
                _buildStatCard(
                  title: "Page Views",
                  value: "200K",
                  startColor: const Color(0xFF3DC1D3),
                  endColor: const Color(0xFF6FE7DB),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ---- Row: Event Statistics & Pie Chart ----
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 300,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27293D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Event Statistics",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Placeholder for a line chart or multi-line chart
                        Expanded(
                          child: Center(
                            child: Text(
                              "Line Chart Placeholder",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 300,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27293D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Engagement Rate",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Placeholder for a pie or radial chart
                        Expanded(
                          child: Center(
                            child: Text(
                              "Pie Chart Placeholder",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ---- Row: Profit Statistics & Bar Chart ----
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 300,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27293D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Profit Statistics",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Placeholder for another line chart
                        Expanded(
                          child: Center(
                            child: Text(
                              "Line Chart Placeholder",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 300,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27293D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Number of Tickets/Week",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Placeholder for a bar chart
                        Expanded(
                          child: Center(
                            child: Text(
                              "Bar Chart Placeholder",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a gradient statistic card
  Widget _buildStatCard({
    required String title,
    required String value,
    required Color startColor,
    required Color endColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
