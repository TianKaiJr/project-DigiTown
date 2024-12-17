import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/_MainScreen_Module/view_models/main_screen_view_model.dart';
import 'package:super_admin_panel/ZTempModule/temp.dart';
import '../view_models/side_menu_view_model.dart';
import '../models/screen_model.dart';
import '../widgets/drawer_list_tile.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SideMenuViewModel>();

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          ...viewModel.menuTitles.map((title) {
            return DrawerListTile(
              title: title,
              svgSrc: "assets/icons/menu_$title.svg",
              press: () {
                final screen = viewModel.getScreens().firstWhere(
                    (screen) => screen.title == title,
                    orElse: () => ScreenModel(
                        title: "Dashboard", screen: const TempPage()));
                context.read<MainScreenViewModel>().onMenuTap(screen.screen);
              },
            );
          }),
        ],
      ),
    );
  }
}
