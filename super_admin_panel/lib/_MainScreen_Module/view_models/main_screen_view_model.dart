// lib/view_models/main_screen_view_model.dart

import 'package:flutter/material.dart';
import '../repositories/screen_repository.dart';

class MainScreenViewModel extends ChangeNotifier {
  final ScreenRepository _screenRepository;

  MainScreenViewModel(this._screenRepository);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ValueNotifier<Widget> currentScreenNotifier =
      ValueNotifier(const Placeholder());

  void onMenuTap(Widget screen) {
    currentScreenNotifier.value = screen;
    notifyListeners();
  }

  List<String> get menuTitles => _screenRepository.getMenuTitles();

  List<Widget> get screens =>
      _screenRepository.getScreens().map((screen) => screen.screen).toList();
}
