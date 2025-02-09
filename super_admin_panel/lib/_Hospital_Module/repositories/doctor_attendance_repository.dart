import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_attendance_model.dart';

class DoctorAttendanceRepository {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('Doctors_Attendence');

  Stream<List<DoctorAttendance>> getDoctorsStream() {
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => DoctorAttendance.fromMap(
            doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addOrUpdateDoctor(DoctorAttendance doctor) async {
    await _collection.doc(doctor.id).set(doctor.toMap());
  }

  Future<void> deleteDoctor(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> toggleAvailability(String id, bool isAvailable) async {
    await _collection.doc(id).update({
      'status': isAvailable ? 'Available' : 'Leave',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
