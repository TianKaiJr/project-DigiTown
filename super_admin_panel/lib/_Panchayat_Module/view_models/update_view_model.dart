import 'dart:io';
import '../models/update_model.dart';
import '../repositories/update_repository.dart';

class UpdateViewModel {
  final _repository = UpdateRepository();

  Future<List<UpdateModel>> getUpdates() async {
    final updates = await _repository.fetchUpdates();
    return updates
        .map((data) => UpdateModel.fromJson(data['id'], data))
        .toList();
  }

  Future<void> createUpdate(String title, String details, File? imageFile) {
    return _repository.addUpdate(title, details, imageFile);
  }

  Future<void> editUpdate(
      String id, String title, String details, File? imageFile) {
    return _repository.editUpdate(id, title, details, imageFile);
  }

  Future<void> deleteUpdate(String id) {
    return _repository.deleteUpdate(id);
  }
}
