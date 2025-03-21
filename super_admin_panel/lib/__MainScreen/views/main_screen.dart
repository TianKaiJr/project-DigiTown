import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/__MainScreen/view_models/main_screen_view_model.dart';
import 'package:super_admin_panel/___Core/Theme/app_pallete.dart';
import 'package:super_admin_panel/__MainScreen/views/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MainScreenViewModel>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: SideMenu(),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppPallete.bgColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<Widget>(
                  valueListenable: context
                      .watch<MainScreenViewModel>()
                      .currentScreenNotifier,
                  builder: (context, screen, child) {
                    return screen;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
