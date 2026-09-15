import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';

// Displays the application settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Logs the user out and returns to the sign-in screen.
  Future<void> _logout(BuildContext context) async {
    final UserService userService = UserService();

    try {
      // Sign out from Firebase if a Firebase account is active.
      if (userService.firebaseUser != null) {
        await userService.signOut();
      }

      // Clear locally saved session/token data.
      await userService.logout();

      if (!context.mounted) return;

      // Return to the sign-in screen and remove previous screens.
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $e',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
        ),
      );
    }
  }

  // Builds the settings screen interface.
  @override
  Widget build(BuildContext context) {
    final themeModel = context.watch<ThemeProvider>();
    final isDark = themeModel.isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF354591),
        foregroundColor: Colors.white,
        elevation: 2,

        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ------------------------------------------
              // Appearance section
              // ------------------------------------------
              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 10),

                child: Text(
                  'Appearance',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF354591),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,

                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),

                  leading: Container(
                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF354591)
                          : const Color(0xFFE9ECFF),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(
                      isDark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,

                      color: isDark
                          ? const Color(0xFFFFD41C)
                          : const Color(0xFF354591),

                      size: 23,
                    ),
                  ),

                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,

                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),

                  subtitle: Text(
                    isDark
                        ? 'Dark theme is currently enabled'
                        : 'Light theme is currently enabled',

                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                    ),
                  ),

                  trailing: Switch(
                    value: themeModel.isDark,

                    onChanged: (_) {
                      themeModel.toggleTheme();
                    },

                    activeThumbColor: const Color(0xFF354591),
                    activeTrackColor: const Color(0xFFBFC7F5),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ------------------------------------------
              // Account section
              // ------------------------------------------
              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 10),

                child: Text(
                  'Account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF354591),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,

                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),

                  leading: Container(
                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8E6),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Icon(
                      Icons.logout,
                      color: Color(0xFFFF6255),
                      size: 22,
                    ),
                  ),

                  title: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6255),
                    ),
                  ),

                  subtitle: Text(
                    'Sign out of your account',

                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                    ),
                  ),

                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFFF6255),
                  ),

                  onTap: () {
                    _logout(context);
                  },
                ),
              ),

              const SizedBox(height: 30),

              // ------------------------------------------
              // App State
              // ------------------------------------------
              Center(
                child: Text(
                  isDark ? 'Dark Mode is active' : 'Light Mode is active',

                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
