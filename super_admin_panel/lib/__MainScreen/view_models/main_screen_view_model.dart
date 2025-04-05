import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_admin_panel/__MainScreen/models/screen_model.dart';
import 'package:super_admin_panel/__MainScreen/repositories/screen_repository.dart';
import 'package:super_admin_panel/___Core/RBAC/role_bloc.dart';

class MainScreenViewModel extends ChangeNotifier {
  final ScreenRepository _screenRepository;
  final BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late ValueNotifier<Widget> currentScreenNotifier;

  MainScreenViewModel(this._screenRepository, this.context) {
    currentScreenNotifier = ValueNotifier(
      const Center(child: CircularProgressIndicator()),
    );
    _initializeScreens(); // ❌ Issue: Not awaited
  }

  /// ✅ Function to initialize screens based on role
  Future<void> _initializeScreens() async {
    // Get initial RoleBloc state
    final roleState = context.read<RoleBloc>().state;

    if (roleState is RoleLoaded) {
      _setScreens(roleState.role);
    } else {
      // Listen for RoleBloc state changes
      context.read<RoleBloc>().stream.listen((state) {
        if (state is RoleLoaded) {
          _setScreens(state.role);
        }
      });
    }
  }

  /// ✅ Updates the screen based on role
  void _setScreens(String role) {
    List<ScreenModel> allowedScreens = _getAllowedScreens(role);

    if (allowedScreens.isNotEmpty) {
      currentScreenNotifier.value =
          allowedScreens.first.screen; // ✅ Correctly setting the default screen
    } else {
      currentScreenNotifier.value = const Center(child: Text("No Access"));
    }
  }

  /// ✅ Updates current screen on menu tap
  void onMenuTap(Widget screen) {
    currentScreenNotifier.value = screen;
  }

  List<ScreenModel> _getAllowedScreens(String role) {
    List<ScreenModel> allScreens = _screenRepository.getScreens();
    List<String> allowedTitles = _getAllowedMenuTitles(role);

    return allScreens
        .where((screen) => allowedTitles.contains(screen.title))
        .toList();
  }

  List<String> _getAllowedMenuTitles(String role) {
    List<String> commonMenus = ["Profile", "Settings"];
    Map<String, List<String>> roleBasedMenus = {
      "p_admin": ["Panchayat"],
      "h_admin": ["Hospital"],
      "t_admin": ["Transport"],
      "pc_admin": ["Palliative Care"],
      "bb_admin": ["Blood Bank"]
    };

    return role == "admin"
        ? _screenRepository.getMenuTitles()
        : [...(roleBasedMenus[role] ?? []), ...commonMenus];
  }
}
