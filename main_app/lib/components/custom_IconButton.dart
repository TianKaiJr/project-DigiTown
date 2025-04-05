import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String imagePath;

  const CustomIconButton({
    Key? key,
    required this.onTap,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Hospital Service', // The text shown on hover or long-press
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
              child: Image.asset(
                imagePath,
                height: 24,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
