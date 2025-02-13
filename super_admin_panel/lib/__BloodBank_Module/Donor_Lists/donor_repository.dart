import 'package:cloud_firestore/cloud_firestore.dart';
import 'donor_model.dart';

class DonorRepository {
  final CollectionReference donorCollection =
      FirebaseFirestore.instance.collection('Blood_Donors_List');

  final DocumentReference idCounterRef = FirebaseFirestore.instance
      .doc('/ID_Counters/permanent_counters_skeleton');

  Future<String> _generateDonorId() async {
    final DocumentSnapshot snapshot = await idCounterRef.get();
    if (!snapshot.exists) {
      await idCounterRef.set({'donor_id': 1});
      return "1";
    }

    int currentId = snapshot['donor_id'];
    int newId = currentId + 1;
    await idCounterRef.update({'donor_id': newId});
    return newId.toString();
  }

  Future<void> addDonor(Donor donor) async {
    String donorId = await _generateDonorId();
    donor.donorId = donorId;
    await donorCollection.doc(donorId).set(donor.toFirestore());
  }

  Future<List<Donor>> getDonors() async {
    final querySnapshot = await donorCollection.get();
    return querySnapshot.docs
        .map((doc) =>
            Donor.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<Donor>> getFilteredDonors(
      {String? gender, String? bloodType}) async {
    Query query = donorCollection;

    if (gender != null) query = query.where('gender', isEqualTo: gender);
    if (bloodType != null) {
      query = query.where('blood_type', isEqualTo: bloodType);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) =>
            Donor.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
