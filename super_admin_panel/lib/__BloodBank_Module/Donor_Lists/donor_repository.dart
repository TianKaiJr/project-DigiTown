import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_admin_panel/__BloodBank_Module/Donor_Lists/donor_model.dart';

class DonorRepository {
  final CollectionReference donorCollection =
      FirebaseFirestore.instance.collection('Blood_Donors_List');

  Future<void> addDonor(Donor donor) async {
    await donorCollection.doc(donor.donorId).set(donor.toFirestore());
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
