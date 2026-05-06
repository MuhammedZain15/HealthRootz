// dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/core/cubit/auth_cubit.dart';
import 'package:grad_project/doctor/doctor_layout.dart';
import 'package:grad_project/patient/features/auth/register_page.dart';
import 'package:grad_project/patient/layout/patient_layout.dart';

import 'app_colors.dart';

import 'generated/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash for at least 2 seconds
    final minDelay = Future.delayed(const Duration(seconds: 2));

    // Try auto-login with stored token
    final authCubit = context.read<AuthCubit>();
    await authCubit.tryAutoLogin();

    // Wait for the minimum splash duration
    await minDelay;

    if (!mounted) return;

    if (authCubit.isAuthenticated) {
      // Navigate based on role
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => authCubit.isDoctor
              ? const DoctorAppLayout()
              : const AppLayout(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.imagesLogo, width: 300, height: 300),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Health",
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                Text(
                  "Rootz",
                  style: TextStyle(
                    color: Color(0xff38B6FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

