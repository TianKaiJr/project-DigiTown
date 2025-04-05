import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../repositories/contact_repository.dart';

class ContactViewModel extends ChangeNotifier {
  final ContactRepository _repository = ContactRepository();

  List<ContactModel> contacts = [];
  List<String> contactTypes = [];
  String selectedType = 'All';
  bool isLoading = false; // Track loading state

  void fetchContacts() async {
    isLoading = true;
    notifyListeners(); // Notify UI to show loader

    print('Fetching contacts for type: $selectedType');
    _repository.getContacts(selectedType).listen((data) {
      contacts = data;
      isLoading = false; // Done loading
      print('Fetched ${contacts.length} contacts');
      notifyListeners();
    }, onError: (_) {
      isLoading = false; // Ensure UI updates on error
      notifyListeners();
    });
  }

  Future<void> fetchContactTypes() async {
    isLoading = true;
    notifyListeners();

    contactTypes = ['All', ...await _repository.getContactTypes()];
    isLoading = false;
    notifyListeners();
  }

  Future<void> addOrUpdateContact(ContactModel contact, File? image) async {
    if (image != null) {
      contact.imageUrl = await _repository.uploadImage(image);
    }
    await _repository.addOrUpdateContact(contact);
    fetchContacts(); // Refresh list after update
  }

  Future<void> deleteContact(String id) async {
    await _repository.deleteContact(id);
    fetchContacts(); // Refresh list after delete
  }
}
