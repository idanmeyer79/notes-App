import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../pages/auth_page.dart';
import '../home_page.dart';
import 'splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoading && authViewModel.currentUser == null) {
          return const SplashScreen();
        }

        if (authViewModel.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final homeViewModel = context.read<HomeViewModel>();
            homeViewModel.setCurrentUserId(authViewModel.currentUser!.uid);
          });

          return const MyHomePage(title: 'Notes');
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final homeViewModel = context.read<HomeViewModel>();
            homeViewModel.clearNotes();
          });

          return const AuthPage();
        }
      },
    );
  }
}
