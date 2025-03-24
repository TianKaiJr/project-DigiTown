import 'custom_icon.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NoNetworkScreen extends StatelessWidget {
  const NoNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Changed background to white
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 140),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors
                        .grey.shade300, // Restored grey circular background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off,
                    size: 50,
                    color: Colors.black, // Changed icon to black
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "You're offline",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Changed text to black
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Check your connection and try again",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black, // Changed text to black
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _onTryAgainPressed(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.black), // Changed outline to black
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Try again",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black, // Changed button text to black
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 150),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconPage(imagePath: "assets/logo.png"),
                    const SizedBox(width: 0.5),
                    const Text(
                      "Digi Kalady",
                      style: TextStyle(
                        color: Colors.black, // Changed text to black
                        fontSize: 25,
                        fontFamily: 'Tungsten',
                        letterSpacing: 2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTryAgainPressed(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white, // Changed loading background to white
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.black, // Changed loading circle color to black
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context);

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoNetworkScreen()),
      );
    }
  }
}
