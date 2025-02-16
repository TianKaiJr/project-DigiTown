import 'package:cloud_firestore/cloud_firestore.dart';

class Donor {
  String donorId;
  String name;
  String gender;
  int age;
  String phoneNumber;
  String? email;
  String bloodType;
  String address;
  String pincode;
  DateTime lastDonationDate;
  bool eligibilityStatus;
  String? healthConditions;
  DateTime registeredDate;

  Donor({
    required this.donorId,
    required this.name,
    required this.gender,
    required this.age,
    required this.phoneNumber,
    this.email,
    required this.bloodType,
    required this.address,
    required this.pincode,
    required this.lastDonationDate,
    required this.eligibilityStatus,
    this.healthConditions,
    required this.registeredDate,
  });

  // Convert Firestore document to Donor object
  factory Donor.fromFirestore(Map<String, dynamic> data, String id) {
    return Donor(
      donorId: id,
      name: data['name'],
      gender: data['gender'],
      age: data['age'],
      phoneNumber: data['phone_number'],
      email: data['email'],
      bloodType: data['blood_type'],
      address: data['address'],
      pincode: data['pincode'],
      lastDonationDate: (data['last_donation_date'] as Timestamp).toDate(),
      eligibilityStatus: data['eligibility_status'],
      healthConditions: data['health_conditions'],
      registeredDate: (data['registered_date'] as Timestamp).toDate(),
    );
  }

  // Convert Donor object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'phone_number': phoneNumber,
      'email': email,
      'blood_type': bloodType,
      'address': address,
      'pincode': pincode,
      'last_donation_date': lastDonationDate,
      'eligibility_status': eligibilityStatus,
      'health_conditions': healthConditions,
      'registered_date': registeredDate,
    };
  }
}
