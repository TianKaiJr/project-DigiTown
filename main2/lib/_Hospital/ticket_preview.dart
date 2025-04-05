import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'hospital.dart';

class TicketPreviewPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final int tokenNumber;
  final String patientName;
  final String phoneNumber;
  final String address;
  final String reason;
  final String doctorName;
  final String hospitalName;
  final String dateString;
  final String department; // Department details

  const TicketPreviewPage({
    Key? key,
    required this.pdfBytes,
    required this.tokenNumber,
    required this.patientName,
    required this.phoneNumber,
    required this.address,
    required this.reason,
    required this.doctorName,
    required this.hospitalName,
    required this.dateString,
    required this.department,
  }) : super(key: key);

  Future<void> _onDownloadPressed() async {
    // Show the OS print/preview dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    // For demonstration, we’ll encode a geo URI in the QR code.
    final qrData = "geo:37.7749,-122.4194"; // Example: opens location in map apps

    return Scaffold(
      appBar: AppBar(
  title: const Text("SUCCESSFUL"),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HospitalPage()), 
        (route) => false, // Clears the navigation stack
      );
    },
  ),
),

      body: Container(
        // A gradient background to mimic a "themed" ticket style
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF512DA8), Color(0xFF673AB7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1) "Appointment Slip" with new font color for legibility
              const Text(
                'Appointment Slip',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Changed to white
                ),
              ),
              const SizedBox(height: 8),

              // The ticket container with bite designs
              ClipPath(
                clipper: TicketClipper(),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 2) Quote with individual colors for "fight," "HEAL," and "thrive"
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text: "fight",
                              style: const TextStyle(color: Colors.blue),
                            ),
                            const TextSpan(
                              text: ", ",
                              style: TextStyle(color: Colors.black87),
                            ),
                            TextSpan(
                              text: "HEAL",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            const TextSpan(
                              text: ", ",
                              style: TextStyle(color: Colors.black87),
                            ),
                            TextSpan(
                              text: "thrive",
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),

                      // 3) Hospital name placed slightly further down
                      const SizedBox(height: 16), // Increased from 8 to 16
                      Text(
                        hospitalName,
                        style: const TextStyle(
                          fontSize: 36, // Large size for logo effect
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // Token number shifted to the right
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Token No: $tokenNumber",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Patient / appointment details with larger text
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Phone: $phoneNumber",
                              style: const TextStyle(fontSize: 20),
                            ),
                            if (address.trim().isNotEmpty)
                              Text(
                                "Address: $address",
                                style: const TextStyle(fontSize: 20),
                              ),
                            if (reason.trim().isNotEmpty)
                              Text(
                                "Reason: $reason",
                                style: const TextStyle(fontSize: 20),
                              ),
                            if (department.trim().isNotEmpty)
                              Text(
                                "Department: $department",
                                style: const TextStyle(fontSize: 20),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              "Doctor: $doctorName",
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Date: $dateString",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Dashed divider for a "tear" effect
                      const _DashedDivider(),
                      const SizedBox(height: 16),

                      // QR code section
                      const Text(
                        "Scan this QR to open location:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 120,
                            gapless: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Icons/images for a hopeful/hospital theme
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital,
                              color: Colors.redAccent, size: 32),
                          const SizedBox(width: 16),
                          Icon(Icons.favorite, color: Colors.pink, size: 32),
                          const SizedBox(width: 16),
                          Icon(Icons.healing, color: Colors.green, size: 32),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Download (print) button
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Download / Print"),
                onPressed: _onDownloadPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom dashed line widget to visually separate
/// different sections within the ticket.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(),
      child: const SizedBox(
        width: double.infinity,
        height: 1,
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A custom clipper that creates an **inward** bite at
/// each corner and at the center on both left & right edges.
class TicketClipper extends CustomClipper<Path> {
  final double cornerBite;
  final double notchRadius;

  const TicketClipper({
    this.cornerBite = 16,
    this.notchRadius = 8,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double centerY = size.height / 2;

    // Start at top-left corner (0,0)
    path.moveTo(0, 0);

    // 1) Top-left corner arc inward
    path.lineTo(cornerBite, 0);
    path.arcToPoint(
      Offset(0, cornerBite),
      radius: Radius.circular(cornerBite),
      clockwise: true, // Arc curves inward
    );

    // 2) Left edge -> center top notch
    path.lineTo(0, centerY - notchRadius);
    // Center left notch (inward arc)
    path.arcToPoint(
      Offset(0, centerY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: true,
    );

    // 3) Left edge -> bottom-left corner
    path.lineTo(0, size.height - cornerBite);
    // Bottom-left corner arc inward
    path.arcToPoint(
      Offset(cornerBite, size.height),
      radius: Radius.circular(cornerBite),
      clockwise: true,
    );

    // 4) Bottom edge -> bottom-right corner
    path.lineTo(size.width - cornerBite, size.height);
    // Bottom-right corner arc inward
    path.arcToPoint(
      Offset(size.width, size.height - cornerBite),
      radius: Radius.circular(cornerBite),
      clockwise: true,
    );

    // 5) Right edge -> center bottom notch
    path.lineTo(size.width, centerY + notchRadius);
    // Center right notch (inward arc)
    path.arcToPoint(
      Offset(size.width, centerY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: true,
    );

    // 6) Right edge -> top-right corner
    path.lineTo(size.width, cornerBite);
    // Top-right corner arc inward
    path.arcToPoint(
      Offset(size.width - cornerBite, 0),
      radius: Radius.circular(cornerBite),
      clockwise: true,
    );

    // Close across top edge
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) =>
      cornerBite != oldClipper.cornerBite ||
      notchRadius != oldClipper.notchRadius;
}
