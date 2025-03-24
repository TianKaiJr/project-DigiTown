import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsPage extends StatelessWidget {
  final CollectionReference contacts =
      FirebaseFirestore.instance.collection('Contact_List');

  void _call(String number) async {
    final Uri callUri = Uri.parse('tel:$number');
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      print('Could not launch $callUri');
    }
  }

  void _whatsapp(String number) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      print('Could not launch $whatsappUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 10.0),
            child: Center(
              child: Text(
                "Contacts",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: contacts.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var contactDocs = snapshot.data!.docs
                    .where((doc) => doc['Contact_Type'] != 'Private')
                    .toList();

                return ListView.builder(
                  itemCount: contactDocs.length,
                  itemBuilder: (context, index) {
                    var contact = contactDocs[index];
                    var name = contact['Contact Name'];
                    var number = contact['Contact Number'];
                    var type = contact['Contact_Type'];
                    var profilePic = contact['Profile Pic'];

                    return Card(
                      color: Colors.deepPurple.shade200,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: profilePic != null && profilePic.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(profilePic),
                              )
                            : CircleAvatar(child: Icon(Icons.person)),
                        title: Text(name),
                        subtitle: Text("$type\n$number"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'call') {
                              _call(number);
                            } else if (value == 'whatsapp') {
                              _whatsapp(number);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'call', child: Text('Call')),
                            PopupMenuItem(
                                value: 'whatsapp', child: Text('WhatsApp')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
