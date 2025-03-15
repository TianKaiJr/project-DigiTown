import 'package:twilio_flutter/twilio_flutter.dart';

class SmsService {
  late TwilioFlutter twilioFlutter;

  SmsService() {
    twilioFlutter = TwilioFlutter(
      accountSid: 'ACc9a75f905c04243222e29ba4d84a5174',           // Replace with your Account SID
      authToken: '39c5b631eb606dd8dad00585161b3d77',             // Replace with your Auth Token
      twilioNumber: '+14255841926', // Replace with your Twilio number
    );
  }

  Future<void> sendAppointmentConfirmation(String toNumber, String message) async {
    try {
      await twilioFlutter.sendSMS(
        toNumber: toNumber,
        messageBody: message,
      );
      print("SMS sent successfully!");
    } catch (e) {
      print("Failed to send SMS: $e");
    }
  }
}
