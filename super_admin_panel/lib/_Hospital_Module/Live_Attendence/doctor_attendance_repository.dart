import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_attendance_model.dart';

class DoctorAttendanceRepository {
  final CollectionReference _doctorsCollection =
      FirebaseFirestore.instance.collection('Doctors');

  /// Fetch the list of doctors
  Stream<List<DoctorAttendance>> getDoctorsStream() {
    return _doctorsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DoctorAttendance.fromMap(doc.id, {
          'name': doc['Name'] as String,
          'status': doc['status'] ?? 'Available', // Default status
        });
      }).toList();
    });
  }

  /// Toggle availability inside the **Doctors** collection (not attendance)
  Future<void> toggleAvailability(String id, bool isAvailable) async {
    await _doctorsCollection.doc(id).update({
      'status': isAvailable ? 'Available' : 'Leave',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
