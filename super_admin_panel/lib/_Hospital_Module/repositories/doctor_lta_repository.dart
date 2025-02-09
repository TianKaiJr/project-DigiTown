import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_lta_model.dart';

class DoctorLTARepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final snapshot = await _firestore.collection('Doctors_Attendence').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, 'name': doc['name']})
        .toList();
  }

  Future<DoctorLTA?> fetchAvailability(String doctorId) async {
    final snapshot =
        await _firestore.collection('Doctors_LTA').doc(doctorId).get();
    if (snapshot.exists) {
      return DoctorLTA.fromFirestore(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> saveAvailability(
      String doctorId, Map<DateTime, bool> availability) async {
    await _firestore.collection('Doctors_LTA').doc(doctorId).set(
          availability
              .map((key, value) => MapEntry(key.toIso8601String(), value)),
        );
  }
}
