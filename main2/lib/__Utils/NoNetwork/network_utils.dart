import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:main2/__Utils/NoNetwork/offline_notification.dart';

class NetworkUtils {
  static Future<void> checkAndProceed(
      BuildContext context, VoidCallback action) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white, // Ensure background is white
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.black, // Set the indicator color to black
          ),
        ),
      );

      // Delay before navigating to NoNetworkScreen
      await Future.delayed(const Duration(seconds: 2));

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to NoNetworkScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NoNetworkScreen()),
      );
      return;
    }

    action(); // Execute the intended action if network is available
  }
}
