import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final UserService _userService = UserService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text controllers.
  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _ageController = TextEditingController();

  final TextEditingController _contactNoController = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Handles Firebase account creation and saves
  // the user's profile data.
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the account using Firebase Authentication.
      final auth.UserCredential credential = await _userService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final auth.User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Unable to create Firebase account.');
      }

      final String username = _usernameController.text.trim();

      final String email = _emailController.text.trim();

      final String firstName = _firstNameController.text.trim();

      final String lastName = _lastNameController.text.trim();

      final String age = _ageController.text.trim();

      final String contactNo = _contactNoController.text.trim();

      // Use the username as the Firebase display name.
      await _userService.updateUsername(username: username);

      // --------------------------------------------------
      // Save this account's profile using its Firebase UID.
      // --------------------------------------------------
      await _userService.saveFirebaseProfile(
        firebaseUser: firebaseUser,
        firstName: firstName,
        lastName: lastName,
        age: age,
        contactNo: contactNo,
        username: username,
        email: email,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      // Return to Sign In after successful registration.
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/signin');
    } on auth.FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message = 'Sign up failed.';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email address is already in use.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'The password is too weak.';
          break;

        case 'operation-not-allowed':
          message = 'Email/password authentication is not enabled.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Sign up failed.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
    }
  }

  // Validates the first name.
  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your first name';
    }

    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }

    return null;
  }

  // Validates the last name.
  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your last name';
    }

    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }

    return null;
  }

  // Validates the age.
  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your age';
    }

    final int? age = int.tryParse(value.trim());

    if (age == null) {
      return 'Age must be a number';
    }

    if (age < 1 || age > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }

  // Validates the contact number.
  String? _validateContactNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your contact number';
    }

    final String contact = value.replaceAll(RegExp(r'[\s\-()]'), '');

    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(contact)) {
      return 'Please enter a valid contact number';
    }

    return null;
  }

  // Validates the username.
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username';
    }

    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Use only letters, numbers, and underscores';
    }

    return null;
  }

  // Validates the email address.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Validates the password.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }

    return null;
  }

  // Releases the controllers when the screen is removed.
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _contactNoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // Creates a reusable text field.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFF354591), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFF354591), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 10.h),

                // NUBD Exchange logo.
                Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  width: 110.r,
                  height: 110.r,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 10.h),

                // Page title.
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF354591),
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Sign up to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 24.h),

                // First Name.
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  validator: _validateFirstName,
                  keyboardType: TextInputType.name,
                ),

                SizedBox(height: 16.h),

                // Last Name.
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  validator: _validateLastName,
                  keyboardType: TextInputType.name,
                ),

                SizedBox(height: 16.h),

                // Age.
                _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  validator: _validateAge,
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 16.h),

                // Contact Number.
                _buildTextField(
                  controller: _contactNoController,
                  label: 'Contact No.',
                  validator: _validateContactNo,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 16.h),

                // Username.
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  validator: _validateUsername,
                  keyboardType: TextInputType.text,
                ),

                SizedBox(height: 16.h),

                // Email Address.
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 16.h),

                // Password.
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  validator: _validatePassword,
                  obscureText: _obscurePassword,
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

                SizedBox(height: 8.h),

                // Password requirements.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password must contain at least 8 characters, '
                    'one uppercase letter, one lowercase letter, '
                    'and one number.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Sign Up button.
                SizedBox(
                  width: double.infinity,
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
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
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: const Color(0xFFFFC325),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 18.h),

                // Back to Sign In.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
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
                                '/signin',
                              );
                            },
                      child: Text(
                        'Sign In',
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

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
