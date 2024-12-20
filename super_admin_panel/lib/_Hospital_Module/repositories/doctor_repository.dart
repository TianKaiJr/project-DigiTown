import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  final _doctorCollection =
      FirebaseFirestore.instance.collection('Doctors_Attendence');
  final _availabilityCollection =
      FirebaseFirestore.instance.collection('Doctors_LTA');

  Future<List<Doctor>> fetchDoctors() async {
    final snapshot = await _doctorCollection.get();
    return snapshot.docs
        .map((doc) => Doctor.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<Map<DateTime, bool>> fetchAvailability(String doctorId) async {
    final snapshot = await _availabilityCollection.doc(doctorId).get();
    if (!snapshot.exists) return {};

    final data = snapshot.data() as Map<String, dynamic>;
    return data
        .map((key, value) => MapEntry(DateTime.parse(key), value as bool));
  }

  Future<void> saveAvailability(
      String doctorId, Map<DateTime, bool> availability) async {
    final availabilityMap = availability
        .map((key, value) => MapEntry(key.toIso8601String(), value));
    await _availabilityCollection.doc(doctorId).set(availabilityMap);
  }
}
