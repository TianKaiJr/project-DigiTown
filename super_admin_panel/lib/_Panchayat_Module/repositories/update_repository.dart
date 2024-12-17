import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<List<Map<String, dynamic>>> fetchUpdates() async {
    final snapshot = await _firestore.collection('News_And_Events').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> addUpdate(String title, String details, File? imageFile) async {
    String imageUrl =
        "https://static.vecteezy.com/system/resources/thumbnails/008/255/803/small_2x/page-not-found-error-404-system-updates-uploading-computing-operation-installation-programs-system-maintenance-a-hand-drawn-layout-template-of-a-broken-robot-illustration-vector.jpg";

    if (imageFile != null) {
      try {
        final ref =
            _storage.ref('News_And_Events/${DateTime.now().toIso8601String()}');
        final uploadTask = await ref.putFile(imageFile);
        imageUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }

    await _firestore.collection('News_And_Events').add({
      'title': title,
      'details': details,
      'imageUrl': imageUrl,
    });
  }

  Future<void> editUpdate(
      String id, String title, String details, File? imageFile) async {
    String imageUrl =
        "https://static.vecteezy.com/system/resources/thumbnails/008/255/803/small_2x/page-not-found-error-404-system-updates-uploading-computing-operation-installation-programs-system-maintenance-a-hand-drawn-layout-template-of-a-broken-robot-illustration-vector.jpg";

    if (imageFile != null) {
      try {
        final ref =
            _storage.ref('News_And_Events/${DateTime.now().toIso8601String()}');
        final uploadTask = await ref.putFile(imageFile);
        imageUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }

    await _firestore.collection('News_And_Events').doc(id).update({
      'title': title,
      'details': details,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deleteUpdate(String id) async {
    try {
      await _firestore.collection('News_And_Events').doc(id).delete();
    } catch (e) {
      print('Failed to delete update: $e');
    }
  }
}
