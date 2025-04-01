import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateModel {
  final String id;
  final String title;
  final String details;
  final String imageUrl;

  UpdateModel({
    required this.id,
    required this.title,
    required this.details,
    required this.imageUrl,
  });

  factory UpdateModel.fromJson(String id, Map<String, dynamic> json) {
    return UpdateModel(
      id: id,
      title: json['title'],
      details: json['details'],
      imageUrl: json['imageUrl'],
    );
  }
}

class NewsEventsScreen extends StatefulWidget {
  const NewsEventsScreen({super.key});

  @override
  State<NewsEventsScreen> createState() => _NewsEventsScreenState();
}

class _NewsEventsScreenState extends State<NewsEventsScreen> {
  final _firestore = FirebaseFirestore.instance;
  late Future<List<UpdateModel>> _updatesFuture;

  @override
  void initState() {
    super.initState();
    _updatesFuture = fetchUpdates();
  }

  Future<List<UpdateModel>> fetchUpdates() async {
    final snapshot = await _firestore.collection('News_And_Events').get();
    return snapshot.docs
        .map((doc) => UpdateModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // appBar: AppBar(title: const Text("News & Events")),
      child: FutureBuilder<List<UpdateModel>>(
        future: _updatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No updates available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final update = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: update.imageUrl,
                    // width: 50,
                    // height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  title: Text(update.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(update.details,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
