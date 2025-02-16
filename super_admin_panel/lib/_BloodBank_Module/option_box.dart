import 'package:flutter/material.dart';

class OptionBox extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const OptionBox({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  _OptionBoxState createState() => _OptionBoxState();
}

class _OptionBoxState extends State<OptionBox> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            color: isHovered ? Colors.redAccent : Colors.red,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isHovered
                ? [const BoxShadow(color: Colors.black26, blurRadius: 10)]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
