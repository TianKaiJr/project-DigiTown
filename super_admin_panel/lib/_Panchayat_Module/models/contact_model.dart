class ContactModel {
  String id;
  String name;
  String designation;
  String number;
  String imageUrl;
  String contactType;

  ContactModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.number,
    required this.imageUrl,
    required this.contactType,
  });

  factory ContactModel.fromMap(String id, Map<String, dynamic> data) {
    return ContactModel(
      id: id,
      name: data['Contact Name'] ?? '',
      designation: data['Contact Designation'] ?? '',
      number: data['Contact Number'] ?? '',
      imageUrl: data['Profile Pic'] ?? '',
      contactType: data['Contact_Type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Contact Name': name,
      'Contact Designation': designation,
      'Contact Number': number,
      'Profile Pic': imageUrl,
      'Contact_Type': contactType,
    };
  }
}
