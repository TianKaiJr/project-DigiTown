import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _profileImage = 'https://via.placeholder.com/150'; // Placeholder image URL
  String _userName = '';
  String _email = '';
  String _contact = '';
  String _address = '';
  final ImagePicker _picker = ImagePicker();

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    TextEditingController _controller = TextEditingController(text: currentValue);
    String? errorText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter $title',
                  errorText: errorText,
                ),
                onChanged: (value) {
                  setState(() {
                    errorText = _validateInput(title, value);
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_validateInput(title, _controller.text) == null) {
                      onSave(_controller.text);
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        errorText = _validateInput(title, _controller.text);
                      });
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? _validateInput(String field, String value) {
    if (value.isEmpty) {
      return '$field cannot be empty';
    }
    if (field == 'Email' && !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    if (field == 'Contact' && !RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  // Function to allow user to choose from camera or gallery
  Future<void> _uploadPhoto() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Take a Photo'),
                onTap: () async {
                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      _profileImage = photo.path;  // Update profile image path
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Choose from Gallery'),
                onTap: () async {
                  final XFile? galleryImage = await _picker.pickImage(source: ImageSource.gallery);
                  if (galleryImage != null) {
                    setState(() {
                      _profileImage = galleryImage.path;  // Update profile image path
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8EC5FC), Color(0xFFE0C3FC)
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1D1D23),
              Color(0xFF0F0B0B),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300], // Light background color for the placeholder
                    child: _profileImage.isEmpty || _profileImage == 'https://via.placeholder.com/150'
                        ? Icon(
                            Icons.camera,
                            size: 40,
                            color: Color(0xFF8EC5FC), // Camera icon color
                          )
                        : ClipOval(
                            child: _profileImage.startsWith('http')
                                ? Image.network(
                                    _profileImage,  // Display URL-based image
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : Image.file(
                                    File(_profileImage), // Display selected file image
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _uploadPhoto();  // Show the upload dialog only when the camera icon is tapped
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: Icon(
                          Icons.camera_alt,
                          color:Color(0xFF8EC5FC),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  _buildEditableSection('User Name', _userName, (newValue) {
                    setState(() {
                      _userName = newValue;
                    });
                  }),
                  _buildEditableSection('Email', _email, (newValue) {
                    setState(() {
                      _email = newValue;
                    });
                  }),
                  _buildEditableSection('Contact', _contact, (newValue) {
                    setState(() {
                      _contact = newValue;
                    });
                  }),
                  _buildEditableSection('Address', _address, (newValue) {
                    setState(() {
                      _address = newValue;
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableSection(String label, String currentValue, Function(String) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8EC5FC),
                        Color(0xFFE0C3FC),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    currentValue.isEmpty ? 'No $label provided' : currentValue,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Color(0xFF8EC5FC)),
                onPressed: () {
                  _showEditDialog(label, currentValue, onSave);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
