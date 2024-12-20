import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_admin_panel/Core/Theme/app_pallete.dart';

class AppTheme {
  // Border decoration function
  static OutlineInputBorder _border(
          [Color color = AppPallete.secondaryColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.bgColor,
    textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
    canvasColor: AppPallete.secondaryColor,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(AppPallete.defaultPadding),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.primaryColor),
      errorBorder: _border(AppPallete.errorColor),
    ),
  );
}
