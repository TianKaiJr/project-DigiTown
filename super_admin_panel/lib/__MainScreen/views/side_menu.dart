import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_admin_panel/__Dashboard/dashboard.dart';
import 'package:super_admin_panel/__MainScreen/view_models/main_screen_view_model.dart';
import 'package:super_admin_panel/___Core/RBAC/role_bloc.dart';
import '../view_models/side_menu_view_model.dart';
import '../models/screen_model.dart';
import '../widgets/drawer_list_tile.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SideMenuViewModel>();
    final mainScreenViewModel = context.read<MainScreenViewModel>();

    return Drawer(
      child: BlocBuilder<RoleBloc, RoleState>(
        builder: (context, state) {
          if (state is RoleLoaded) {
            final userRole = state.role;

            // Get allowed menu titles based on role
            final allowedMenuTitles =
                _getAllowedMenuTitles(userRole, viewModel.menuTitles);

            if (allowedMenuTitles.isNotEmpty) {
              // Immediately set the first screen as the default screen
              final firstScreen = viewModel.getScreens().firstWhere(
                    (screen) => screen.title == allowedMenuTitles.first,
                    orElse: () => ScreenModel(
                      title: "Dashboard",
                      screen: const DashboardScreen(),
                    ),
                  );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                mainScreenViewModel.onMenuTap(firstScreen.screen);
              });
            }

            return ListView(
              children: [
                DrawerHeader(
                  child: Image.asset("assets/images/logo.png"),
                ),
                ...allowedMenuTitles.map((title) {
                  return DrawerListTile(
                    title: title,
                    svgSrc: "assets/icons/menu_$title.svg",
                    press: () {
                      final screen = viewModel.getScreens().firstWhere(
                            (screen) => screen.title == title,
                            orElse: () => ScreenModel(
                              title: "Dashboard",
                              screen: const DashboardScreen(),
                            ),
                          );
                      mainScreenViewModel.onMenuTap(screen.screen);
                    },
                  );
                }),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  List<String> _getAllowedMenuTitles(String role, List<String> menuTitles) {
    List<String> commonMenus = ["Profile", "Settings"];
    Map<String, List<String>> roleBasedMenus = {
      "p_admin": ["Panchayat"],
      "h_admin": ["Hospital"],
      "t_admin": ["Transport"],
      "pc_admin": ["Palliative Care"],
      "bb_admin": ["Blood Bank"]
    };

    if (role == "admin") {
      return menuTitles;
    } else {
      List<String> roleMenus = roleBasedMenus[role] ?? [];
      return [...roleMenus, ...commonMenus];
    }
  }
}
