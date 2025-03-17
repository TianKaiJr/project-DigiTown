import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:super_admin_panel/__Profile/profile_page.dart';

class AdminManagerScreen extends StatefulWidget {
  const AdminManagerScreen({super.key});

  @override
  _AdminManagerScreenState createState() => _AdminManagerScreenState();
}

class _AdminManagerScreenState extends State<AdminManagerScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  bool _status = false;

  Future<void> _addAdmin() async {
    // const String firebaseProjectId = "project-digitown"; // 🔹 Change this
    const String firebaseApiKey =
        "AIzaSyAlbJccw6r2OXDDlg6YiLkkm0Ti1mz1yB8"; // 🔹 Change this

    try {
      // Firebase REST API URL for creating a user
      String url =
          "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$firebaseApiKey";

      // Send HTTP request to create the user
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "returnSecureToken": false, // 🔹 Prevents login replacement
        }),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String userId = data["localId"];

        // Store admin details in Firestore
        await FirebaseFirestore.instance
            .collection('Admin_Requests')
            .doc(userId)
            .set({
          "email": _emailController.text.trim(),
          "name": _nameController.text.trim(),
          "role": _roleController.text.trim(),
          "status": _status,
          "timestamp": Timestamp.now(),
        });

        _clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin account created successfully!")),
        );
      } else {
        throw Exception(data["error"]["message"]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _updateAdmin(String docId) async {
    await FirebaseFirestore.instance
        .collection('Admin_Requests')
        .doc(docId)
        .update({
      "email": _emailController.text,
      "name": _nameController.text,
      "password": _passwordController.text,
      "role": _roleController.text,
      "status": _status,
    });
    _clearFields();
  }

  Future<void> _deleteAdmin(String docId) async {
    await FirebaseFirestore.instance
        .collection('Admin_Requests')
        .doc(docId)
        .delete();
  }

  void _clearFields() {
    _emailController.clear();
    _nameController.clear();
    _passwordController.clear();
    _roleController.clear();
    setState(() => _status = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBar(title: "Admin Manager"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Email", _emailController),
            _buildTextField("Name", _nameController),
            _buildTextField("Password", _passwordController),
            _buildTextField("Role", _roleController),
            DropdownButton<bool>(
              value: _status,
              onChanged: (bool? newValue) {
                setState(() => _status = newValue!);
              },
              items: const [
                DropdownMenuItem(value: true, child: Text("Active")),
                DropdownMenuItem(value: false, child: Text("Inactive")),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: _addAdmin, child: const Text("Add Admin")),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Admin_Requests')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var admins = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: admins.length,
                    itemBuilder: (context, index) {
                      var admin = admins[index];
                      return ListTile(
                        title: Text(admin['name']),
                        subtitle: Text(admin['email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _emailController.text = admin['email'];
                                _nameController.text = admin['name'];
                                _passwordController.text = admin['password'];
                                _roleController.text = admin['role'];
                                setState(() => _status = admin['status']);
                                _updateAdmin(admin.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAdmin(admin.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
