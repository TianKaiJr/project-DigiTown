import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final _contactCollection =
      FirebaseFirestore.instance.collection('Contact_List');
  final _classificationCollection =
      FirebaseFirestore.instance.collection('Contact_Classification');

  Stream<List<ContactModel>> getContacts(String contactType) {
    Query query = _contactCollection;
    if (contactType != 'All') {
      query = query.where('Contact_Type', isEqualTo: contactType);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ContactModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<String>> getContactTypes() async {
    final snapshot = await _classificationCollection.get();
    return snapshot.docs
        .map((doc) => doc.data()['Contact_Type'] as String?)
        .where((type) => type != null)
        .cast<String>()
        .toList();
  }

  Future<void> addOrUpdateContact(ContactModel contact) async {
    if (contact.id.isEmpty) {
      await _contactCollection.add(contact.toMap());
    } else {
      await _contactCollection.doc(contact.id).update(contact.toMap());
    }
  }

  Future<void> deleteContact(String id) async {
    await _contactCollection.doc(id).delete();
  }

  Future<String> uploadImage(File image) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref =
        FirebaseStorage.instance.ref().child('profile_images/$fileName');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
}
