import 'package:flutter/material.dart';
import 'package:super_admin_panel/__MainScreen/models/screen_model.dart';
import '../repositories/screen_repository.dart';

class SideMenuViewModel extends ChangeNotifier {
  final ScreenRepository _screenRepository;

  SideMenuViewModel(this._screenRepository);

  List<String> get menuTitles => _screenRepository.getMenuTitles();

  List<ScreenModel> getScreens() {
    return _screenRepository.getScreens(); // Use repository to get screens
  }
}
