import 'package:flutter/material.dart';

class DoctorLTADialog extends StatelessWidget {
  const DoctorLTADialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Available'),
          ],
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Unavailable'),
          ],
        ),
      ],
    );
  }
}
