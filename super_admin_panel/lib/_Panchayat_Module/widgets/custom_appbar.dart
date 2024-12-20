import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue, // Set your desired background color
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor:
              Colors.transparent, // Prevents overlap with the container color
          elevation: 0, // Removes default AppBar shadow
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
