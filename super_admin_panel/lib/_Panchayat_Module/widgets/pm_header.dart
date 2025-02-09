import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_admin_panel/__Core/Controllers/menu_app_controller.dart';
import 'package:super_admin_panel/__Core/Responsive/responsive.dart';

class PMHeader extends StatelessWidget {
  final String name;
  const PMHeader({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        Expanded(
          child: Center(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
