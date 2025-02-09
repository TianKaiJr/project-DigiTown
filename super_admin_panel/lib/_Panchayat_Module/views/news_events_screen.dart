import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:super_admin_panel/__Core/Theme/app_pallete.dart';
import 'package:super_admin_panel/_Panchayat_Module/models/update_model.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/custom_appbar.dart';
import 'package:super_admin_panel/_Panchayat_Module/widgets/update_view_popup.dart';
import '../view_models/update_view_model.dart';
import '../widgets/add_update_popup.dart';

class NewsEventsScreen extends StatefulWidget {
  const NewsEventsScreen({super.key});

  @override
  State<NewsEventsScreen> createState() => _NewsEventsScreenState();
}

class _NewsEventsScreenState extends State<NewsEventsScreen> {
  final _viewModel = UpdateViewModel();
  late Future<List<UpdateModel>> _updatesFuture;

  @override
  void initState() {
    super.initState();
    _updatesFuture = _viewModel.getUpdates();
  }

  void _refreshUpdates() {
    setState(() {
      _updatesFuture = _viewModel.getUpdates();
    });
  }

  void _deleteUpdate(String id) async {
    await _viewModel.deleteUpdate(id);
    _refreshUpdates();
  }

  void _editUpdate(String id, String title, String details, String imageUrl) {
    // Show a popup or navigate to another screen for editing
    showDialog(
      context: context,
      builder: (context) => AddUpdatePopup(
        viewModel: _viewModel,
        existingUpdate: UpdateModel(
            id: id, title: title, details: details, imageUrl: imageUrl),
      ),
    ).then((_) => _refreshUpdates());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "News & Events",
      ),
      body: FutureBuilder<List<UpdateModel>>(
        future: _updatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load updates"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No updates available"));
          }

          final updates = snapshot.data!;
          return ListView.builder(
            itemCount: updates.length,
            itemBuilder: (context, index) {
              final update = updates[index];
              return GestureDetector(
                onTap: () {
                  showCustomDialog(
                      context, update.title, update.details, update.imageUrl);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: AppPallete.primaryColor,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: update.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  update.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                update.details,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded,
                                  color: Color.fromARGB(255, 22, 118, 25)),
                              onPressed: () {
                                _editUpdate(update.id, update.title,
                                    update.details, update.imageUrl);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteUpdate(update.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddUpdatePopup(viewModel: _viewModel),
          ).then((_) => _refreshUpdates());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
