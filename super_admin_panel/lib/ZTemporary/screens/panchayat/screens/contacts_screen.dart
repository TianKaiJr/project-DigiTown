import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/ZTemporary/constants.dart';
import 'package:super_admin_panel/ZTemporary/controllers/menu_app_controller.dart';
import 'package:super_admin_panel/ZTemporary/responsive.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  String imageURL =
      'https://runinall.com/9607-large_default/37-1-2-nov-mpch-master-bushing-insert-bowl.jpg'; // Default image URL
  String selectedType = 'All';
  String selectedContactType = '';
  List<String> categories = ['All'];
  List<String> contactTypes = [];
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadContactTypes();
  }

  Future<void> loadCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Contact_Classification')
          .get();

      List<String> retrievedCategories = snapshot.docs
          .map((doc) => doc.data()['Contact_Type'] as String?)
          .where((type) => type != null)
          .cast<String>()
          .toList();

      setState(() {
        categories = ['All', ...retrievedCategories]..sort();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> loadContactTypes() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Contact_Classification')
          .get();

      List<String> retrievedTypes = snapshot.docs
          .map((doc) => doc.data()['Contact_Type'] as String?)
          .where((type) => type != null)
          .cast<String>()
          .toList();

      setState(() {
        contactTypes = retrievedTypes;
      });
    } catch (e) {
      print('Error fetching contact types: $e');
    }
  }

  Future<void> uploadImage() async {
    if (selectedImage == null) return;

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await ref.putFile(selectedImage!);
      imageURL = await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      imageURL =
          'https://runinall.com/9607-large_default/37-1-2-nov-mpch-master-bushing-insert-bowl.jpg';
    }
  }

  Stream<QuerySnapshot> getContactsStream() {
    if (selectedType == 'All') {
      return FirebaseFirestore.instance.collection('Contact_List').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('Contact_List')
          .where('Contact_Type', isEqualTo: selectedType)
          .snapshots();
    }
  }

  Future<void> showContactDialog({DocumentSnapshot? document}) async {
    if (document != null) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      nameController.text = data['Contact Name'] ?? '';
      designationController.text = data['Contact Designation'] ?? '';
      numberController.text = data['Contact Number'] ?? '';
      imageURL = data['Profile Pic'] ??
          'https://runinall.com/9607-large_default/37-1-2-nov-mpch-master-bushing-insert-bowl.jpg';
      selectedContactType = data['Contact_Type'] ?? '';
    } else {
      nameController.clear();
      designationController.clear();
      numberController.clear();
      imageURL =
          'https://runinall.com/9607-large_default/37-1-2-nov-mpch-master-bushing-insert-bowl.jpg';
      selectedImage = null;
      selectedContactType = '';
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(document == null ? 'New Contact' : 'Edit Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.single.path != null) {
                      setState(() {
                        selectedImage = File(result.files.single.path!);
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : (imageURL.isNotEmpty
                            ? NetworkImage(imageURL)
                            : const AssetImage('')) as ImageProvider,
                    child: selectedImage == null && imageURL.isEmpty
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: designationController,
                  decoration: const InputDecoration(labelText: 'Designation'),
                ),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(
                  height: 10,
                ),
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSelectedItems: true,
                  ),
                  items: contactTypes,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Contact Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedContactType = newValue ?? '';
                    });
                  },
                  selectedItem: selectedContactType,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedImage != null) {
                  await uploadImage();
                }
                Map<String, dynamic> contactData = {
                  'Contact Name': nameController.text.trim(),
                  'Contact Designation': designationController.text.trim(),
                  'Contact Number': numberController.text.trim(),
                  'Profile Pic': imageURL,
                  'Contact_Type': selectedContactType,
                };

                if (document == null) {
                  await FirebaseFirestore.instance
                      .collection('Contact_List')
                      .add(contactData);
                } else {
                  await FirebaseFirestore.instance
                      .collection('Contact_List')
                      .doc(document.id)
                      .update(contactData);
                }

                Navigator.pop(context);
              },
              child: Text(document == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteContact(DocumentSnapshot document) async {
    try {
      await FirebaseFirestore.instance
          .collection('Contact_List')
          .doc(document.id)
          .delete();
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                if (!Responsive.isDesktop(context))
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: context.read<MenuAppController>().controlMenu,
                  ),
                if (!Responsive.isMobile(context))
                  Text(
                    "Contacts",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                if (!Responsive.isMobile(context))
                  Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
              ],
            ),
            centerTitle: true,
            elevation: 5,
            backgroundColor: bgColor,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownSearch<String>(
              popupProps: const PopupProps.menu(
                constraints: BoxConstraints(maxHeight: 225),
                showSelectedItems: true,
              ),
              items: categories,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Contact Type",
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedType = newValue;
                  });
                }
              },
              selectedItem: selectedType,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getContactsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  List<DocumentSnapshot> contactList = snapshot.data!.docs;
                  if (contactList.isEmpty) {
                    return const Center(
                      child: Text('No contacts available'),
                    );
                  }

                  return ListView.builder(
                    itemCount: contactList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = contactList[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String name = data['Contact Name'];
                      String designation = data['Contact Designation'];
                      String number = data['Contact Number'];
                      String image = data['Profile Pic'] ??
                          'https://runinall.com/9607-large_default/37-1-2-nov-mpch-master-bushing-insert-bowl.jpg';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(image),
                        ),
                        title: Text(name),
                        subtitle: Text('$designation\n$number'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  showContactDialog(document: document),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteContact(document),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('Error loading contacts'),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showContactDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
