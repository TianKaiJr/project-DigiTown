import 'package:twilio_flutter/twilio_flutter.dart';

class SmsService {
  late TwilioFlutter twilioFlutter;

  SmsService() {
    twilioFlutter = TwilioFlutter(
      accountSid: 'AC700ce6647c2d0e257a4a36718449905b',           // Replace with your Account SID
      authToken: '87976e827762881c8eb5657a06234ffd',             // Replace with your Auth Token
      twilioNumber: '+15074364272', // Replace with your Twilio number
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
