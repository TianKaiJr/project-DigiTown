import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  File? _profileImage;
  final _picker = ImagePicker();
  bool _isEditing = false;
  bool _isLoading = true;

  // Admin Data
  String fullName = "Admin Name";
  String email = "admin@example.com";
  String phone = "";
  String jobTitle = "System Administrator";
  String username = "admin123";
  String accountStatus = "Active"; // Updated from Admin_Requests
  String assignedRole = "Super Admin"; // Updated from Admin_Requests

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No logged-in user found.");
        return;
      }

      String userEmail = user.email!;
      print("Fetching data for admin with email: $userEmail");

      // Query Admin_Requests collection to find admin by email
      QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('Admin_Requests')
          .where('email', isEqualTo: userEmail)
          .limit(1) // Only need one matching document
          .get();

      if (requestSnapshot.docs.isNotEmpty) {
        var adminDoc = requestSnapshot.docs.first;
        fullName = adminDoc['name'] ?? fullName;
        email = adminDoc['email'] ?? email;
        accountStatus =
            adminDoc['status'] == true ? "Active" : "Inactive"; // Get status
        assignedRole = adminDoc['role'] ?? assignedRole; // Get role
      } else {
        print("No admin found with email: $userEmail");
      }

      // Fetch additional admin details from Admin_Details
      DocumentSnapshot detailsSnapshot = await FirebaseFirestore.instance
          .collection('Admin_Details')
          .doc(userEmail) // Use email as document ID
          .get();

      if (detailsSnapshot.exists) {
        phone = detailsSnapshot['phone'] ?? phone;
        jobTitle = detailsSnapshot['jobTitle'] ?? jobTitle;
        username = detailsSnapshot['username'] ?? username;
      } else {
        print("No details found in Admin_Details for email: $userEmail");
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching admin data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAdminData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No logged-in user found.");
      return;
    }
    String userEmail = user.email!;

    await FirebaseFirestore.instance
        .collection('Admin_Details')
        .doc(userEmail)
        .set({
      "email": email,
      "name": fullName,
      "phone": phone,
      "jobTitle": jobTitle,
      "username": username,
      "accountStatus": accountStatus, // Save status
      "assignedRole": assignedRole, // Save role
    });

    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBar(title: "\t\tProfile"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Full Name", fullName, null,
                      isEditable: false),
                  _buildTextField("Email", email, null, isEditable: false),
                  _buildTextField("Phone", phone, (value) => phone = value),
                  _buildTextField(
                      "Job Title", jobTitle, (value) => jobTitle = value),
                  _buildTextField("Username", username, null, isEditable: true),
                  _buildTextField("Account Status", accountStatus, null,
                      isEditable: false),
                  _buildTextField("Assigned Role", assignedRole, null,
                      isEditable: false),
                  const SizedBox(height: 20),
                  _isEditing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _saveAdminData,
                              child: const Text("Save"),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                setState(() => _isEditing = false);
                              },
                              child: const Text("Cancel"),
                            ),
                          ],
                        )
                      : Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _isEditing = true);
                            },
                            child: const Text("Edit Profile"),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, String value, Function(String)? onChanged,
      {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        readOnly: !isEditable || !_isEditing,
        onChanged: onChanged,
      ),
    );
  }
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ProfileAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: false,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
