import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/__MainScreen/view_models/main_screen_view_model.dart';
import 'package:super_admin_panel/__MainScreen/views/side_menu.dart';
import 'package:super_admin_panel/___Core/Theme/app_pallete.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainScreenViewModel>();

    return Scaffold(
      key: viewModel.scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: SideMenu()),
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
                  valueListenable: viewModel.currentScreenNotifier,
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
