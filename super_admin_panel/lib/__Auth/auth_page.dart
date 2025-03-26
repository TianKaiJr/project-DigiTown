import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_admin_panel/__Auth/Login/login_page.dart';
import 'package:super_admin_panel/__MainScreen/views/main_screen.dart';
import 'package:super_admin_panel/___Core/RBAC/role_bloc.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userEmail = snapshot.data?.email ?? '';

          // Inject RoleBloc and fetch user role
          return BlocProvider(
            create: (context) => RoleBloc()..add(FetchUserRole(userEmail)),
            child: const MainScreen(),
          );
        } else {
          return const DarkLoginScreen();
        }
      },
    );
  }
}
