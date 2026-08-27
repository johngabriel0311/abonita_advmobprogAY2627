import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();

    // Enhancement 3:
    // Retrieves the saved user data from UserService
    // using the User model.
    _userFuture = _userService.getUser();
  }

  // Logs the current user out and returns to the sign-in screen.
  Future<void> _logout() async {
    await _userService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
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

        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'No user data found.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
            ),
          );
        }

        final user = snapshot.data!;

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
                        child: CachedNetworkImage(
                          imageUrl: user.image,
                          width: 100.r,
                          height: 100.r,
                          fit: BoxFit.cover,

                          placeholder: (context, url) {
                            return Container(
                              width: 100.r,
                              height: 100.r,
                              color: const Color(0xFFF5F2E8),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFFC325),
                                      ),
                                ),
                              ),
                            );
                          },

                          errorWidget: (context, url, error) {
                            return Container(
                              width: 100.w,
                              height: 100.h,
                              color: const Color(0xFFF5F2E8),
                              child: Icon(
                                Icons.person,
                                size: 55.sp,
                                color: const Color(0xFF354591),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Full name.
                      Text(
                        '${user.firstName} ${user.lastName}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Username.
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFC325),
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
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),

                      _buildDivider(),

                      _buildInfoRow(
                        icon: Icons.people_outline,
                        label: 'Gender',
                        value: user.gender,
                      ),

                      _buildDivider(),

                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'User ID',
                        value: '#${user.id}',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 26.h),

                // Logout button.
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: Icon(Icons.logout, size: 20.sp),
                    label: Text(
                      'Log Out',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6255),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds one row of profile information.
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

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
