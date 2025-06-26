import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../pages/login_page.dart';
import '../home_page.dart';
import 'splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Show splash screen while checking authentication status
        if (authViewModel.isLoading && authViewModel.currentUser == null) {
          return const SplashScreen();
        }

        if (authViewModel.isLoggedIn) {
          // Set the current user ID in HomeViewModel
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final homeViewModel = context.read<HomeViewModel>();
            homeViewModel.setCurrentUserId(authViewModel.currentUser!.uid);
          });

          return const MyHomePage(title: 'Notes App');
        } else {
          // Clear notes when user logs out
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final homeViewModel = context.read<HomeViewModel>();
            homeViewModel.clearNotes();
          });

          return const LoginPage();
        }
      },
    );
  }
}
