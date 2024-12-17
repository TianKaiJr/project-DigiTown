import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_admin_panel/_Hospital_Module/models/doctor_attendence_model.dart';

class DoctorAttendenceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<DoctorAttendence>> fetchDoctors() {
    return _firestore
        .collection('Doctors_Attendence')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DoctorAttendence.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addDoctor(DoctorAttendence doctor) async {
    await _firestore
        .collection('Doctors_Attendence')
        .doc(doctor.name)
        .set(doctor.toMap());
  }

  Future<void> updateDoctor(String id, DoctorAttendence doctor) async {
    await _firestore
        .collection('Doctors_Attendence')
        .doc(id)
        .update(doctor.toMap());
  }

  Future<void> deleteDoctor(String id) async {
    await _firestore.collection('Doctors_Attendence').doc(id).delete();
  }

  Future<void> toggleAvailability(
      String id, bool isAvailable, String timestamp) async {
    await _firestore.collection('Doctors_Attendence').doc(id).update({
      'status': isAvailable ? 'Available' : 'Leave',
      'timestamp': timestamp,
    });
  }
}
