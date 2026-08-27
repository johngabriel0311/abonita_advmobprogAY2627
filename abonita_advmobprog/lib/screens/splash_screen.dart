import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await _userService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      final userData = await _userService.getUserData();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home', arguments: userData);
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    // Enhancement 1:
    // Custom splash screen UI with the application logo and loading indicator while authentication is checked.
    return Scaffold(
      backgroundColor: const Color(0xFF354591),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NUBD splash logo.
            Image.asset(
              'assets/images/splashscreen_logo.png',
              width: 180.r,
              height: 180.r,
              fit: BoxFit.contain,
            ),

            SizedBox(height: 34.h),

            // Yellow loading indicator.
            SizedBox(
              width: 28.r,
              height: 28.r,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFC325),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
