import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taxi_app/Screens/LogOut/logout_screen.dart';
import 'package:taxi_app/Screens/Login/login_screen.dart';
import 'package:taxi_app/Screens/Main/mainscreen.dart';
import 'package:taxi_app/Screens/OneTimeProfile/profile_data_page.dart';
import 'package:taxi_app/__Core/auth_page.dart';
import 'package:taxi_app/__Core/constants.dart';
import 'package:taxi_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: kPrimaryColor,
            shape: const StadiumBorder(),
            maximumSize: const Size(double.infinity, 56),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: kPrimaryLightColor,
          iconColor: kPrimaryColor,
          prefixIconColor: kPrimaryColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthPage(),
        '/login': (context) => LoginScreen(),
        '/profile_data': (context) => const ProfileDataPage(),
        '/mainscreen': (context) => MainScreen(),
        '/logout': (context) => LogOutPage(),
      },
    );
  }
}
