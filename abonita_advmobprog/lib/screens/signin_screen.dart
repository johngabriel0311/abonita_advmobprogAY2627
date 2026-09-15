import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../services/user_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final UserService _userService = UserService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Handles DummyJSON or Firebase authentication.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final usernameOrEmail = _usernameController.text.trim();
    final password = _passwordController.text;

    // --------------------------------------------------
    // Try DummyJSON first.
    // --------------------------------------------------
    try {
      final response = await _userService.loginUser(usernameOrEmail, password);

      // Save DummyJSON user data.
      await _userService.saveUserData(response);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacementNamed(context, '/home', arguments: response);

      return;
    } catch (_) {
      // DummyJSON login failed.
      // Continue and try Firebase.
    }

    // --------------------------------------------------
    // Try Firebase Authentication.
    // --------------------------------------------------
    try {
      final auth.UserCredential credential = await _userService.signIn(
        email: usernameOrEmail,
        password: password,
      );

      final auth.User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Unable to retrieve Firebase user.');
      }

      // --------------------------------------------------
      // IMPORTANT:
      // Load the profile belonging specifically to this
      // Firebase user's UID.
      //
      // This restores:
      // - First Name
      // - Last Name
      // - Username
      // - Email
      // - Age
      // - Contact Number
      // - Gender
      // - Profile Image
      // --------------------------------------------------
      await _userService.saveFirebaseUserData(firebaseUser);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacementNamed(context, '/home');
    } on auth.FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message = 'Login failed.';

      if (e.code == 'user-not-found') {
        message = 'No Firebase account found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.message != null) {
        message = e.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: $e',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
        ),
      );
    }
  }

  // Releases the text controllers when the screen is removed.
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Sign In UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),

          child: Form(
            key: _formKey,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                // NUBD Exchange logo.
                Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  width: 150.r,
                  height: 150.r,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 20.h),

                // Welcome text.
                Text(
                  'Welcome, Nationalian!',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF354591),
                  ),
                ),

                SizedBox(height: 30.h),

                // Username field.
                TextFormField(
                  controller: _usernameController,

                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),

                  decoration: InputDecoration(
                    labelText: 'Username',

                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),

                      borderSide: const BorderSide(
                        color: Color(0xFF354591),
                        width: 1.5,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),

                      borderSide: const BorderSide(
                        color: Color(0xFF354591),
                        width: 2,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Password field.
                TextFormField(
                  controller: _passwordController,

                  obscureText: _obscurePassword,

                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),

                  decoration: InputDecoration(
                    labelText: 'Password',

                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),

                      borderSide: const BorderSide(
                        color: Color(0xFF354591),
                        width: 1.5,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),

                      borderSide: const BorderSide(
                        color: Color(0xFF354591),
                        width: 2,
                      ),
                    ),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,

                        color: const Color(0xFF354591),
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                // Login button.
                SizedBox(
                  width: double.infinity,
                  height: 40.h,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF354591),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),

                    child: _isLoading
                        ? SizedBox(
                            width: 24.r,
                            height: 24.r,

                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            'Sign In',

                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: const Color(0xFFFFC325),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Sign Up link.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      'Don\'t have an account?',

                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/signup',
                              );
                            },

                      child: Text(
                        'Sign Up',

                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF354591),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
