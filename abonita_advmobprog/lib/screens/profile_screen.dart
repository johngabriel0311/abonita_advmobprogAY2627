import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();

    // Enhancement 3:
    // Retrieves the saved user data from UserService.
    _userFuture = _userService.getUserData();
  }

  // Refreshes the profile information.
  void _refreshProfile() {
    setState(() {
      _userFuture = _userService.getUserData();
    });
  }

  // Shows the Update Username dialog.
  Future<void> _showUpdateUsernameDialog(Map<String, dynamic> userData) async {
    // Keep the username as a normal String instead of using a
    // TextEditingController. This avoids controller lifecycle issues
    // when the dialog is closed.
    String usernameValue = userData['username']?.toString() ?? '';

    final String? username = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Update Username',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextFormField(
            initialValue: usernameValue,
            style: const TextStyle(fontFamily: 'Poppins'),
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              usernameValue = value;
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                // Simply close the dialog.
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                final value = usernameValue.trim();

                if (value.isEmpty) {
                  Navigator.of(dialogContext).pop('');
                  return;
                }

                if (value.length < 3) {
                  Navigator.of(dialogContext).pop(' ');
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF354591),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || username == null) return;

    // Validate the username after the dialog closes.
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a username.')));
      return;
    }

    if (username == ' ') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username must be at least 3 characters.'),
        ),
      );
      return;
    }

    try {
      // Update Firebase display name if this is a Firebase account.
      if (_userService.firebaseUser != null) {
        await _userService.updateUsername(username: username);
      }

      // Save the updated username locally.
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('username', username);

      if (!mounted) return;

      _refreshProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update username: $e')));
    }
  }

  // Shows the Change Password dialog.
  Future<void> _showChangePasswordDialog(Map<String, dynamic> userData) async {
    final currentPasswordController = TextEditingController();

    final newPasswordController = TextEditingController();

    final confirmPasswordController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;
        bool obscureCurrent = true;
        bool obscureNew = true;
        bool obscureConfirm = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Change Password',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Form(
                  key: formKey,

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        enabled: !isLoading,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureCurrent = !obscureCurrent;
                              });
                            },
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your current password';
                          }

                          return null;
                        },
                      ),

                      SizedBox(height: 14.h),

                      TextFormField(
                        controller: newPasswordController,
                        enabled: !isLoading,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a new password';
                          }

                          if (value.length < 8) {
                            return 'Minimum of 8 characters';
                          }

                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Add an uppercase letter';
                          }

                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Add a lowercase letter';
                          }

                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Add a number';
                          }

                          return null;
                        },
                      ),

                      SizedBox(height: 14.h),

                      TextFormField(
                        controller: confirmPasswordController,
                        enabled: !isLoading,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm your password';
                          }

                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          // Password changes require an active
                          // Firebase Authentication account.
                          if (_userService.firebaseUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password changes are available for Firebase accounts.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            final email = userData['email'] ?? '';

                            await _userService.resetPasswordFromCurrentPassword(
                              currentPassword: currentPasswordController.text,
                              newPassword: newPasswordController.text,
                              email: email,
                            );

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password changed successfully.'),
                              ),
                            );
                          } on auth.FirebaseAuthException catch (e) {
                            setDialogState(() {
                              isLoading = false;
                            });

                            String message = 'Failed to change password.';

                            if (e.code == 'wrong-password') {
                              message = 'Current password is incorrect.';
                            } else if (e.code == 'requires-recent-login') {
                              message =
                                  'Please sign in again before changing your password.';
                            } else if (e.message != null) {
                              message = e.message!;
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          } catch (e) {
                            setDialogState(() {
                              isLoading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to change password: $e'),
                              ),
                            );
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF354591),
                    foregroundColor: Colors.white,
                  ),

                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Change',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  // Shows the Delete Account confirmation dialog.
  Future<void> _showDeleteAccountDialog(Map<String, dynamic> userData) async {
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;
        bool obscurePassword = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Delete Account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'This action cannot be undone. Enter your password to confirm account deletion.',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),

                  SizedBox(height: 16.h),

                  TextField(
                    controller: passwordController,
                    enabled: !isLoading,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your password.'),
                              ),
                            );
                            return;
                          }

                          if (_userService.firebaseUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Account deletion is available for Firebase accounts.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            final email = userData['email'] ?? '';

                            await _userService.deleteAccount(
                              email: email,
                              password: passwordController.text,
                            );

                            // Clear locally saved session data.
                            await _userService.logout();

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/signin',
                              (route) => false,
                            );
                          } on auth.FirebaseAuthException catch (e) {
                            setDialogState(() {
                              isLoading = false;
                            });

                            String message = 'Failed to delete account.';

                            if (e.code == 'wrong-password') {
                              message = 'Incorrect password.';
                            } else if (e.code == 'requires-recent-login') {
                              message =
                                  'Please sign in again before deleting your account.';
                            } else if (e.message != null) {
                              message = e.message!;
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          } catch (e) {
                            setDialogState(() {
                              isLoading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete account: $e'),
                              ),
                            );
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6255),
                    foregroundColor: Colors.white,
                  ),

                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
  }

  // Determines which authentication method was used.
  String LoginType() {
    if (_userService.firebaseUser != null) {
      return 'Firebase';
    }

    return 'DummyJSON';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Unable to load profile.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No user data found.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
            ),
          );
        }

        final user = snapshot.data!;

        final String firstName = user['firstName']?.toString() ?? '';

        final String lastName = user['lastName']?.toString() ?? '';

        final String username = user['username']?.toString() ?? '';

        final String email = user['email']?.toString() ?? '';

        final String gender = user['gender']?.toString() ?? '';

        final String age = user['age']?.toString() ?? '';

        final String contactNo = user['contactNo']?.toString() ?? '';

        final String image = user['image']?.toString() ?? '';

        final String loginType = LoginType();

        final String fullName = '$firstName $lastName'.trim();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          body: SingleChildScrollView(
            padding: EdgeInsets.all(14.r),

            child: Column(
              children: [
                // Profile header card.
                Container(
                  width: double.infinity,

                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 22.h,
                  ),

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      // Profile image.
                      ClipOval(
                        child: image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: image,
                                width: 100.r,
                                height: 100.r,
                                fit: BoxFit.cover,

                                placeholder: (context, url) {
                                  return Container(
                                    width: 100.r,
                                    height: 100.r,
                                    color: const Color(0xFFF5F2E8),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFFFFC325),
                                            ),
                                      ),
                                    ),
                                  );
                                },

                                errorWidget: (context, url, error) {
                                  return _buildDefaultAvatar();
                                },
                              )
                            : _buildDefaultAvatar(),
                      ),

                      SizedBox(height: 16.h),

                      // Full name.
                      Text(
                        fullName.isEmpty ? username : fullName,
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Username.
                      if (username.isNotEmpty)
                        Text(
                          '@$username',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFFC325),
                          ),
                        ),

                      SizedBox(height: 8.h),

                      // Login type.
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF354591,
                          ).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          loginType == 'Firebase'
                              ? 'Firebase Account'
                              : 'DummyJSON Account',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF354591),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                // User information card.
                Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      if (email.isNotEmpty)
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: email,
                        ),

                      if (email.isNotEmpty &&
                          (age.isNotEmpty || contactNo.isNotEmpty))
                        _buildDivider(),

                      if (age.isNotEmpty)
                        _buildInfoRow(
                          icon: Icons.cake_outlined,
                          label: 'Age',
                          value: age,
                        ),

                      if (age.isNotEmpty && contactNo.isNotEmpty)
                        _buildDivider(),

                      if (contactNo.isNotEmpty)
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Contact',
                          value: contactNo,
                        ),

                      if (contactNo.isNotEmpty && gender.isNotEmpty)
                        _buildDivider(),

                      if (gender.isNotEmpty)
                        _buildInfoRow(
                          icon: Icons.people_outline,
                          label: 'Gender',
                          value: gender,
                        ),

                      if (gender.isNotEmpty && user['id'] != null)
                        _buildDivider(),

                      if (user['id'] != null && user['id'] != 0)
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'User ID',
                          value: '#${user['id']}',
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                // Account actions.
                Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      // Update username.
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF354591),
                        ),

                        title: Text(
                          'Update Username',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        trailing: const Icon(Icons.chevron_right),

                        onTap: () {
                          _showUpdateUsernameDialog(user);
                        },
                      ),

                      const Divider(height: 1),

                      // Change password.
                      ListTile(
                        leading: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF354591),
                        ),

                        title: Text(
                          'Change Password',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        trailing: const Icon(Icons.chevron_right),

                        onTap: () {
                          _showChangePasswordDialog(user);
                        },
                      ),

                      const Divider(height: 1),

                      // Delete account.
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFFF6255),
                        ),

                        title: Text(
                          'Delete Account',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF6255),
                          ),
                        ),

                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFFF6255),
                        ),

                        onTap: () {
                          _showDeleteAccountDialog(user);
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 26.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // Builds the default profile avatar.
  Widget _buildDefaultAvatar() {
    return Container(
      width: 100.r,
      height: 100.r,
      color: const Color(0xFFF5F2E8),
      child: Icon(Icons.person, size: 55.sp, color: const Color(0xFF354591)),
    );
  }

  // Builds one row of profile information.
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),

      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: const Color(0xFFFFC325)),

          SizedBox(width: 12.w),

          SizedBox(
            width: 75.w,

            child: Text(
              label,

              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a divider between profile information rows.
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
