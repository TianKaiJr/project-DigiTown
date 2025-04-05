import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? ontap;
  const MyListTile({super.key, required this.icon, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black,
          ),
          onTap: ontap,
          title: Text(
            text,
            style: const TextStyle(color: Color.fromARGB(255, 13, 12, 12)),
          ),
      ),
    );
  }
}
