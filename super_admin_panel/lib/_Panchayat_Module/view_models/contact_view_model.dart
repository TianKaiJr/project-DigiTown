import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../repositories/contact_repository.dart';

class ContactViewModel extends ChangeNotifier {
  final ContactRepository _repository = ContactRepository();

  List<ContactModel> contacts = [];
  List<String> contactTypes = [];
  String selectedType = 'All';

  void fetchContacts() async {
    print('Fetching contacts for type: $selectedType');
    _repository.getContacts(selectedType).listen((data) {
      contacts = data;
      print('Fetched ${contacts.length} contacts');
      notifyListeners();
    });
  }

  Future<void> fetchContactTypes() async {
    contactTypes = ['All', ...await _repository.getContactTypes()];
    notifyListeners();
  }

  Future<void> addOrUpdateContact(ContactModel contact, File? image) async {
    if (image != null) {
      contact.imageUrl = await _repository.uploadImage(image);
    }
    await _repository.addOrUpdateContact(contact);
  }

  Future<void> deleteContact(String id) async {
    await _repository.deleteContact(id);
  }
}
