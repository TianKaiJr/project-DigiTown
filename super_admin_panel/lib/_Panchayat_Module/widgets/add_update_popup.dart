import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Panchayat_Module/models/update_model.dart';
import '../view_models/update_view_model.dart';

class AddUpdatePopup extends StatefulWidget {
  final UpdateViewModel viewModel;
  final UpdateModel? existingUpdate;

  const AddUpdatePopup({
    super.key,
    required this.viewModel,
    this.existingUpdate,
  });

  @override
  State<AddUpdatePopup> createState() => _AddUpdatePopupState();
}

class _AddUpdatePopupState extends State<AddUpdatePopup> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();

    // If there's an existing update, pre-populate the fields with the current data
    if (widget.existingUpdate != null) {
      _titleController.text = widget.existingUpdate!.title;
      _detailsController.text = widget.existingUpdate!.details;
      _selectedFile = null; // Keep the existing image unless changed
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width *
            0.6, // Adjust width to fit the ratio
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side for image
                    Expanded(
                      flex: 1, // 1 part
                      child: Center(
                        child: _selectedFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 150,
                                  width: 150,
                                  child: Image.file(
                                    _selectedFile!,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              )
                            : widget.existingUpdate?.imageUrl != null
                                ? GestureDetector(
                                    onTap:
                                        _pickFile, // Allow the user to pick a new image
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        height: 150,
                                        width: 150,
                                        child: Image.network(
                                          widget.existingUpdate!.imageUrl,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap:
                                        _pickFile, // Allow the user to pick an image
                                    child: DottedBorder(
                                      color: Colors.grey,
                                      dashPattern: const [10, 4],
                                      radius: const Radius.circular(10),
                                      borderType: BorderType.RRect,
                                      strokeCap: StrokeCap.round,
                                      child: const SizedBox(
                                        height: 250,
                                        width: 250,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.folder_open,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 15),
                                            Text(
                                              'Select Your Image',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(
                        width: 20), // Space between left and right side
                    // Right side for title and details
                    Expanded(
                      flex: 3, // 3 parts
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _detailsController,
                            decoration: const InputDecoration(
                              labelText: 'Details',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 7,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Fixed bottom buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () async {
                    // If it's an existing update, update it instead of creating a new one
                    if (widget.existingUpdate != null) {
                      // Call update function (you need to implement this in your ViewModel)
                      await widget.viewModel.editUpdate(
                        widget.existingUpdate!.id,
                        _titleController.text,
                        _detailsController.text,
                        _selectedFile,
                      );
                    } else {
                      // Create a new update
                      await widget.viewModel.createUpdate(
                        _titleController.text,
                        _detailsController.text,
                        _selectedFile,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
